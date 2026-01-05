import express from 'express';
import { body } from 'express-validator';
import * as vehicleController from '../controllers/vehicle.controller.js';
import { verifyToken } from '../middlewares/auth.middleware.js';

const router = express.Router();

// Validation rules
const vehicleValidation = [
  body('type').notEmpty().withMessage('Vehicle type is required').isString(),
  body('color').notEmpty().withMessage('Color is required').isString(),
  body('licensePlate').notEmpty().withMessage('License plate is required').isString(),
  body('description').optional().isString()
];

// Routes
// Áp dụng verifyToken cho tất cả các route để bảo mật
// router.use(verifyToken);

router.get('/', vehicleController.getVehicles);
router.get('/:id', vehicleController.getVehicle);
router.post('/', vehicleValidation, vehicleController.createVehicle);
router.put('/:id', vehicleValidation, vehicleController.updateVehicle);
router.delete('/:id', vehicleController.deleteVehicle);

export default router;
