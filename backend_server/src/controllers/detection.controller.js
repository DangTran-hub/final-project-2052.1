import * as detectionService from '../services/detection.service.js';
import { validationResult } from 'express-validator';
import createError from 'http-errors';

export const getDetections = async (req, res, next) => {
  try {
    const data = await detectionService.getAllDetections();
    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
};

export const getDetection = async (req, res, next) => {
  try {
    const { id } = req.params;
    const data = await detectionService.getDetectionById(id);
    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
};

export const createDetection = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw createError(400, { message: 'Validation Error', errors: errors.array() });
    }

    const data = await detectionService.createDetection(req.body);
    res.status(201).json({ success: true, data });
  } catch (error) {
    next(error);
  }
};

export const updateDetection = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw createError(400, { message: 'Validation Error', errors: errors.array() });
    }

    const { id } = req.params;
    const data = await detectionService.updateDetection(id, req.body);
    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
};

export const deleteDetection = async (req, res, next) => {
  try {
    const { id } = req.params;
    await detectionService.deleteDetection(id);
    res.status(200).json({ success: true, message: 'Deleted successfully' });
  } catch (error) {
    next(error);
  }
};
