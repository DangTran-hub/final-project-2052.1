import { db } from '../config/firebase.js';
import { config } from '../config/config.js';
import logger from '../utils/logger.js';

export const saveDetection = async (data) => {
  try {
    if (!db) {
      logger.warn('Firestore not initialized, skipping save');
      return;
    }
    
    const docRef = await db.collection(config.firebase.collection).add({
      ...data,
      createdAt: new Date(), // Server timestamp
    });
    
    logger.info(`Document written with ID: ${docRef.id}`);
    return docRef.id;
  } catch (error) {
    logger.error('Error adding document: ', error);
    throw error;
  }
};
