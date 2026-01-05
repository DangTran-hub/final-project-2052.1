import { messaging } from '../config/firebase.js';
import logger from '../utils/logger.js';

export const sendDetectionNotification = async (detectionData) => {
  try {
    if (!messaging) {
      logger.warn('Firebase Messaging not initialized, skipping notification');
      return;
    }

    // Tùy chỉnh nội dung thông báo dựa trên hành động
    let title = 'Cảnh báo từ thiết bị!';
    let body = `Thiết bị ${detectionData.deviceId} gửi dữ liệu mới.`;

    if (detectionData.method === 'PIR') {
      title = 'Phát hiện chuyển động!';
      body = `Cảm biến PIR tại ${detectionData.deviceId} phát hiện chuyển động nghi vấn.`;
    } else if (detectionData.method === 'AUDIO') {
      title = 'Phát hiện tiếng ồn lớn!';
      body = `Cảm biến âm thanh tại ${detectionData.deviceId} vượt ngưỡng cho phép.`;
    }

    // Gửi thông báo đến topic 'mouse_alerts' mà Mobile App đã subscribe
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: detectionData.type || 'INFO',
        detectionId: detectionData.id || '',
        deviceId: detectionData.deviceId,
        method: detectionData.method || 'NONE'
      },
      topic: 'mouse_alerts',
    };

    const response = await messaging.send(message);
    logger.info('Successfully sent message:', response);
  } catch (error) {
    logger.error('Error sending message:', error);
  }
};
