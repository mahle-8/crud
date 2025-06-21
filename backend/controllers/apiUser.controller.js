import UserModel from "../models/user.model.js";
import apiUserModel from "../models/apiUser.model.js";
import { encryptPassword, comparePassword } from "../library/appBcrypt.js";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import { console } from "inspector";
dotenv.config();
class apiUserController {
  async register(req, res) {
    try {
      const { username, email, password_hash, status_id } = req.body;

      // 1. Validaciones básicas
      if (!username || !email || !password_hash || !status_id) {
        return res.status(400).json({ error: "Required fields are missing" });
      }

      if (password_hash.length < 8) {
        return res.status(400).json({
          error: "The password must be at least 8 characters long.",
        });
      }

      // 2. Verificar si el usuario ya existe
      const existingUser = await UserModel.findByName(username);
      if (existingUser) {
        return res
          .status(409)
          .json({ error: "The username is already in use" });
      }

      // 3. Encriptar contraseña
      const passwordHash = await encryptPassword(password_hash);

      // 4. Generar token API key (usado como token JWT aquí)
      const tempUserData = {
        username,
        email,
        status: status_id,
      };

      const apiKey = jwt.sign(tempUserData, process.env.JWT_SECRET, {
        expiresIn: "1h",
        algorithm: "HS256",
      });

      // 5. Usar procedimiento almacenado para crear user y api_user
      const result = await apiUserModel.createUserWithApiUser({
        username,
        email,
        passwordHash,
        statusId: status_id,
        apiKey,
      });

      return res.status(201).json({
        message: "User and API user created successfully",
        userId: result.userId,
        apiUserId: result.apiUserId,
        apiKey,
      });
    } catch (error) {
      console.error("Registration error:", error);
      res
        .status(500)
        .json({ error: "Internal Server Error", details: error.message });
    }
  }

  async showActive(req, res) {
    try {
      const userModel = await apiUserModel.showActiveApiUsers();
      if (!userModel || userModel.length === 0) {
        return res.status(404).json({ error: "No active users found" });
      }
      res.status(200).json({
        message: "Users retrieved successfully",
        data: userModel,
      });
    } catch (error) {
      console.error("Error fetching users:", error);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
  async delete(req, res) {
    try {
      const id = req.params.id;
      // Basic validate
      if (!id) {
        return res.status(400).json({ error: "Required fields are missing" });
      }
      // Verify if the User already exists
      const deleteApiUserModel = await apiUserModel.delete(id);
      res.status(201).json({
        message: "User delete successfully",
        data: deleteApiUserModel,
      });
    } catch (error) {
      console.error("Error in registration:", error);
      res
        .status(500)
        .json({ error: "Internal Server Error", details: error.message });
    }
  }

  async findById(req, res) {
    try {
      const id = req.params.id;
      // Basic validate
      if (!id) {
        return res.status(400).json({ error: "Required fields are missing" });
      }
      // Verify if the User already exists
      const existingApiUserModel = await apiUserModel.findById(id);
      if (!existingApiUserModel) {
        return res.status(409).json({ error: "The User No already exists" });
      }
      res.status(201).json({
        message: "User successfully",
        data: existingApiUserModel,
      });
    } catch (error) {
      console.error("Error in registration:", error);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
  async findByIdActive(req, res) {
    try {
      const id = req.params.id;
      // Basic validate
      if (!id) {
        return res.status(400).json({ error: "Required fields are missing" });
      }
      // Verify if the User already exists
      const existingApiUserModel = await apiUserModel.findByIdActive(id);
      if (!existingApiUserModel) {
        return res.status(409).json({ error: "The User No already exists" });
      }
      res.status(201).json({
        message: "User successfully",
        data: existingApiUserModel,
      });
    } catch (error) {
      console.error("Error in registration:", error);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
  async update(req, res) {
    try {
      const id = parseInt(req.params.id);
      const { username, passwordHash, isActive } = req.body;

      // Validaciones básicas
      if (
        isNaN(id) ||
        !username ||
        !passwordHash ||
        typeof isActive !== "number"
      ) {
        return res
          .status(400)
          .json({ error: "Required fields are missing or invalid types" });
      }

      // Verificar existencia del api_user
      const existing = await apiUserModel.findById(id);
      if (!existing) {
        return res.status(404).json({ error: "The API user does not exist" });
      }

      // Ejecutar actualización vía procedimiento almacenado
      const updated = await apiUserModel.update(id, {
        username,
        passwordHash,
        isActive,
      });

      if (!updated || !updated.updated_user_id) {
        return res.status(500).json({ error: "Update failed" });
      }

      res.status(200).json({
        message: "API user and associated user updated successfully",
        data: updated,
      });
    } catch (error) {
      console.error("Error updating API user:", error);
      res
        .status(500)
        .json({ error: "Internal Server Error", details: error.message });
    }
  }
  async login(req, res) {
    try {
      const { user, password } = req.body;
      if (!user || !password) {
        return res.status(400).json({ error: "Required fields are missing" });
      }

      const existingUser = await apiUserModel.findByName(user);
      if (!existingUser) {
        return res.status(404).json({ error: "User not found" });
      }

      const passwordMatch = await comparePassword(
        password,
        existingUser.password_hash
      );
      if (!passwordMatch) {
        return res.status(401).json({ error: "Invalid password" });
      }

      const apiUser = await apiUserModel.findByIdActive(existingUser.id);
      if (!apiUser) {
        return res
          .status(403)
          .json({ error: "API user is not active or doesn't exist" });
      }

      await UserModel.updateLogin(existingUser.id);

      const token = jwt.sign(
        {
          id: existingUser.id,
          email: existingUser.email,
          status: existingUser.status_id,
          api_user_id: apiUser.id,
        },
        process.env.JWT_SECRET,
        { expiresIn: "1h", algorithm: "HS256" }
      );

      // Guardar el token como api_key
      await apiUserModel.updateApiKey(existingUser.id, token);

      res.status(200).json({
        message: "API login successful",
        user: {
          id: existingUser.id,
          username: existingUser.username,
          email: existingUser.email,
          apiUserId: apiUser.id,
          apiKey: token,
        },
      });
    } catch (error) {
      console.error("API login error:", error);
      res
        .status(500)
        .json({ error: "Internal Server Error", details: error.message });
    }
  }
}

export default new apiUserController();
