import express from 'express';
import { body } from 'express-validator';
import * as detectionController from '../controllers/detection.controller.js';
import { verifyToken } from '../middlewares/auth.middleware.js';

const router = express.Router();

// Validation rules
const detectionValidation = [
  body('confidence').isFloat({ min: 0, max: 1 }).withMessage('Confidence must be between 0 and 1'),
  body('location').notEmpty().withMessage('Location is required').isString(),
  body('imageUrl').optional().isURL().withMessage('Image URL must be valid')
];

// Routes
// Áp dụng verifyToken cho tất cả các route bên dưới (hoặc từng route cụ thể)
router.use(verifyToken);

router.get('/', detectionController.getDetections);
router.get('/:id', detectionController.getDetection);
router.post('/', detectionValidation, detectionController.createDetection);
router.put('/:id', detectionValidation, detectionController.updateDetection);
router.delete('/:id', detectionController.deleteDetection);

export default router;
