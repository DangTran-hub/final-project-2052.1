import { db } from '../config/firebase.js';
import { config } from '../config/config.js';
import createError from 'http-errors';

const collection = db.collection(config.firebase.collection);

export const getAllDetections = async () => {
  try {
    // Lấy 50 bản ghi mới nhất
    const snapshot = await collection.orderBy('timestamp', 'desc').limit(50).get();
    return snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
        // Convert Firestore Timestamp to Date object if necessary
        timestamp: data.timestamp && data.timestamp.toDate ? data.timestamp.toDate() : data.timestamp
      };
    });
  } catch (error) {
    throw createError(500, error.message);
  }
};

export const getDetectionById = async (id) => {
  try {
    const doc = await collection.doc(id).get();
    if (!doc.exists) {
      throw createError(404, `Detection with id ${id} not found`);
    }
    const data = doc.data();
    return { 
      id: doc.id, 
      ...data,
      timestamp: data.timestamp && data.timestamp.toDate ? data.timestamp.toDate() : data.timestamp
    };
  } catch (error) {
    throw error.status ? error : createError(500, error.message);
  }
};

export const createDetection = async (data) => {
  try {
    const newDetection = {
      ...data,
      timestamp: new Date(), // Server timestamp
      createdAt: new Date()
    };
    const docRef = await collection.add(newDetection);
    return { id: docRef.id, ...newDetection };
  } catch (error) {
    throw createError(500, error.message);
  }
};

export const updateDetection = async (id, data) => {
  try {
    const docRef = collection.doc(id);
    const doc = await docRef.get();
    if (!doc.exists) {
      throw createError(404, `Detection with id ${id} not found`);
    }
    
    await docRef.update(data);
    return { id, ...data };
  } catch (error) {
    throw error.status ? error : createError(500, error.message);
  }
};

export const deleteDetection = async (id) => {
  try {
    const docRef = collection.doc(id);
    const doc = await docRef.get();
    if (!doc.exists) {
      throw createError(404, `Detection with id ${id} not found`);
    }
    
    await docRef.delete();
    return { message: 'Deleted successfully', id };
  } catch (error) {
    throw error.status ? error : createError(500, error.message);
  }
};
