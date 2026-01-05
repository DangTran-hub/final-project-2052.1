import admin from 'firebase-admin';
import createError from 'http-errors';
import logger from '../utils/logger.js';
import { db } from '../config/firebase.js';

export const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw createError(401, 'Unauthorized: No token provided');
    }

    const token = authHeader.split('Bearer ')[1];

    try {
      // 1. Xác thực token với Firebase Auth
      const decodedToken = await admin.auth().verifyIdToken(token);
      const uid = decodedToken.uid;

      // 2. Kiểm tra và đồng bộ User vào Firestore
      const userRef = db.collection('users').doc(uid);
      const userDoc = await userRef.get();

      if (!userDoc.exists) {
        // Nếu user chưa tồn tại trong Firestore, tạo mới
        const newUser = {
          uid: uid,
          email: decodedToken.email || '',
          name: decodedToken.name || decodedToken.email || 'Unknown User',
          picture: decodedToken.picture || '',
          role: 'user', // Mặc định là user thường
          createdAt: new Date(),
          lastLogin: new Date()
        };
        await userRef.set(newUser);
        logger.info(`Created new user profile for ${uid}`);
        req.user = newUser;
      } else {
        // Nếu đã tồn tại, cập nhật thời gian đăng nhập cuối
        await userRef.update({ lastLogin: new Date() });
        req.user = userDoc.data();
      }
      
      next();
    } catch (error) {
      logger.error('Token verification failed:', error);
      throw createError(401, 'Unauthorized: Invalid token');
    }
  } catch (error) {
    next(error);
  }
};
