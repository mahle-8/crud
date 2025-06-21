import { Router } from "express";
import ProfileController from "../controllers/profile.controller.js";

const router = Router();
const name = '/profile';

// Rutas públicas (sin middleware)
router.route(name)
  .post(ProfileController.register) // Crear nuevo perfil
  .get(ProfileController.show);     // Mostrar todos los perfiles

router.route(`${name}/:id`)
  .get(ProfileController.findById)  // Mostrar perfil por ID
  .put(ProfileController.update)    // Actualizar perfil por ID
  .delete(ProfileController.delete);// Eliminar perfil por ID

export default router;
