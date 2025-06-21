import { Router } from "express";
import RoleController from '../controllers/role.controller.js';

const router = Router();
const name = '/role';

// Rutas públicas (sin verifyToken)
router.route(name)
  .post(RoleController.register) // Crear nuevo rol
  .get(RoleController.show);     // Mostrar todos los roles

router.route(`${name}/:id`)
  .get(RoleController.findById)  // Mostrar rol por ID
  .put(RoleController.update)    // Actualizar rol por ID
  .delete(RoleController.delete);// Eliminar rol por ID

export default router;
