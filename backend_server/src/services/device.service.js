import { db } from '../config/firebase.js';
import logger from '../utils/logger.js';

// Cache thiết bị để giảm số lần đọc DB
let deviceCache = {};

export const getDeviceInfo = async (deviceId) => {
  try {
    // 1. Kiểm tra cache trước
    if (deviceCache[deviceId]) {
      return deviceCache[deviceId];
    }

    // 2. Nếu không có trong cache, đọc từ Firestore
    const docRef = db.collection('devices').doc(deviceId);
    const doc = await docRef.get();

    if (doc.exists) {
      const data = doc.data();
      // Lưu vào cache
      deviceCache[deviceId] = {
        location: data.location || 'Unknown Location',
        name: data.name || deviceId
      };
      return deviceCache[deviceId];
    } else {
      // Nếu thiết bị chưa tồn tại trong DB, tạo mới mặc định
      await docRef.set({
        location: 'Unknown Location',
        name: deviceId,
        createdAt: new Date(),
        status: 'online'
      });
      
      deviceCache[deviceId] = { location: 'Unknown Location', name: deviceId };
      return deviceCache[deviceId];
    }
  } catch (error) {
    logger.error(`Error getting device info for ${deviceId}:`, error);
    return { location: 'Unknown', name: deviceId };
  }
};

export const updateDeviceStatus = async (deviceId, status) => {
  try {
    await db.collection('devices').doc(deviceId).set({
      status: status,
      lastSeen: new Date()
    }, { merge: true });
  } catch (error) {
    logger.error(`Error updating status for ${deviceId}:`, error);
  }
};
