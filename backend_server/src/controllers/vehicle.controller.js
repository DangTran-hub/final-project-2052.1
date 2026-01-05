import * as vehicleService from '../services/vehicle.service.js';
import { validationResult } from 'express-validator';
import createError from 'http-errors';

export const getVehicles = async (req, res, next) => {
  try {
    const data = await vehicleService.getAllVehicles();
    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
};

export const getVehicle = async (req, res, next) => {
  try {
    const { id } = req.params;
    const data = await vehicleService.getVehicleById(id);
    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
};

export const createVehicle = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw createError(400, { message: 'Validation Error', errors: errors.array() });
    }

    const data = await vehicleService.createVehicle(req.body);
    res.status(201).json({ success: true, data });
  } catch (error) {
    next(error);
  }
};

export const updateVehicle = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw createError(400, { message: 'Validation Error', errors: errors.array() });
    }

    const { id } = req.params;
    const data = await vehicleService.updateVehicle(id, req.body);
    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
};

export const deleteVehicle = async (req, res, next) => {
  try {
    const { id } = req.params;
    await vehicleService.deleteVehicle(id);
    res.status(200).json({ success: true, message: 'Vehicle deleted successfully' });
  } catch (error) {
    next(error);
  }
};
