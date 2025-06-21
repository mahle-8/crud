import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();

export const verifyToken = (requiredRole) => {
  return (req, res, next) => {
    const authHeader = req.header("Authorization");
    if (!authHeader) {
      return res.status(401).json({ error: "Access denied. No token provided" });
    }

    // Extrae el token sin el prefijo "Bearer "
    const token = authHeader.replace("Bearer ", "").trim();

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Validar rol según el payload
      if (requiredRole === "api_user" && !decoded.api_user_id) {
        return res.status(403).json({ error: "Access denied for non-api user" });
      }
      if (requiredRole === "web_user" && !decoded.web_user_id) {
        return res.status(403).json({ error: "Access denied for non-web user" });
      }

      req.user = decoded; // guardar info del token para usar en controladores
      next();
    } catch (err) {
      return res.status(400).json({ error: "Invalid Token" });
    }
  };
};