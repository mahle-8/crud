import { Router } from "express";
import webUserController from "../controllers/webUser.controller.js";
import { verifyToken } from '../middleware/authMiddleware.js';

const router = Router();
const name = "/webUser";
const nameLogin = "/webLogin";

// Rutas públicas
router.route(name)
  .post(webUserController.register);    // Crear web_user

router.route(nameLogin)
  .post(webUserController.login);       // Login web_user

// Rutas protegidas con middleware para web_user
router.route(name)
  .get(verifyToken("web_user"), webUserController.showActive); // Ver todos los web_user

router.route(`${name}/:id`)
  .get(verifyToken("web_user"), webUserController.findById)    // Ver web_user por ID
  .put(verifyToken("web_user"), webUserController.update)      // Actualizar web_user
  .delete(verifyToken("web_user"), webUserController.delete);  // Eliminar web_user

export default router;
