import { db } from '../config/firebase.js';
import createError from 'http-errors';

// Sử dụng collection 'vehicles' trong Firestore
const collection = db.collection('vehicles');

export const getAllVehicles = async () => {
  try {
    const snapshot = await collection.get();
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    throw createError(500, error.message);
  }
};

export const getVehicleById = async (id) => {
  try {
    const doc = await collection.doc(id).get();
    if (!doc.exists) {
      throw createError(404, `Vehicle with id ${id} not found`);
    }
    return { id: doc.id, ...doc.data() };
  } catch (error) {
    throw error.status ? error : createError(500, error.message);
  }
};

export const createVehicle = async (data) => {
  try {
    const newVehicle = {
      ...data,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    const docRef = await collection.add(newVehicle);
    return { id: docRef.id, ...newVehicle };
  } catch (error) {
    throw createError(500, error.message);
  }
};

export const updateVehicle = async (id, data) => {
  try {
    const docRef = collection.doc(id);
    const doc = await docRef.get();
    if (!doc.exists) {
      throw createError(404, `Vehicle with id ${id} not found`);
    }
    
    const updateData = {
      ...data,
      updatedAt: new Date()
    };
    
    await docRef.update(updateData);
    return { id, ...updateData };
  } catch (error) {
    throw error.status ? error : createError(500, error.message);
  }
};

export const deleteVehicle = async (id) => {
  try {
    const docRef = collection.doc(id);
    const doc = await docRef.get();
    if (!doc.exists) {
      throw createError(404, `Vehicle with id ${id} not found`);
    }
    
    await docRef.delete();
    return { message: 'Deleted successfully', id };
  } catch (error) {
    throw error.status ? error : createError(500, error.message);
  }
};
