import { Router } from "express";
import apiUserController from "../controllers/apiUser.controller.js"
import { verifyToken } from '../middleware/authMiddleware.js';

const router = Router();
const name = "/apiUser";
const nameLogin = "/apiLogin";

// Rutas públicas
router.route(name)
  .post(apiUserController.register);    // Crear api_user

router.route(nameLogin)
  .post(apiUserController.login);       // Login api_user

// Rutas protegidas con middleware
router.route(name)
  .get(verifyToken("api_user"), apiUserController.showActive); // Ver todos los api_user

router.route(`${name}/:id`)
  .get(verifyToken("api_user"), apiUserController.findById)    // Ver api_user por ID
  .put(verifyToken("api_user"), apiUserController.update)      // Actualizar api_user
  .delete(verifyToken("api_user"), apiUserController.delete);  // Eliminar api_user

export default router;