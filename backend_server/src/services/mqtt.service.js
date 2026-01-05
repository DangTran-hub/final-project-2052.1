import mqtt from 'mqtt';
import { config } from '../config/config.js';
import logger from '../utils/logger.js';
import * as firestoreService from './firestore.service.js';
import * as notificationService from './notification.service.js';
import * as deviceService from './device.service.js';

let client;

export const connect = () => {
  const connectOptions = {
    clientId: `backend_server_${Math.random().toString(16).slice(2, 8)}`,
    username: config.mqtt.username,
    password: config.mqtt.password,
    clean: true,
    reconnectPeriod: 5000,
    connectTimeout: 30000,
    rejectUnauthorized: true, // EMQX Cloud uses valid public certs
  };

  logger.info(`Connecting to MQTT Broker: ${config.mqtt.brokerUrl}`);
  
  client = mqtt.connect(config.mqtt.brokerUrl, connectOptions);

  client.on('connect', () => {
    logger.info(`Connected to MQTT Broker as ${connectOptions.clientId}`);
    
    // Subscribe to topic pattern
    client.subscribe(config.mqtt.topicPattern, { qos: 1 }, (err) => {
      if (!err) {
        logger.info(`Subscribed to topic: ${config.mqtt.topicPattern}`);
      } else {
        logger.error('Subscription error:', err);
      }
    });
    
    // Subscribe to status topic to track online/offline
    const statusTopic = config.mqtt.topicPattern.replace('+/telemetry', '+/status');
    client.subscribe(statusTopic, { qos: 1 });
  });

  client.on('message', async (topic, message) => {
    try {
      const payloadStr = message.toString();
      logger.info(`Received message on ${topic}: ${payloadStr}`);
      
      const payload = JSON.parse(payloadStr);
      
      // Extract deviceId from topic (iot/rodent/DEVICE_ID/telemetry)
      const topicParts = topic.split('/');
      // Topic format: iot/rodent/esp32_node_01/telemetry
      const deviceId = topicParts[2]; 
      const messageType = topicParts[3]; // telemetry, status, event...

      // Handle Status Message
      if (messageType === 'status') {
        await deviceService.updateDeviceStatus(deviceId, payload.status);
        return;
      }

      // Get Device Info (Location) from DB
      const deviceInfo = await deviceService.getDeviceInfo(deviceId);

      // Chuẩn hóa dữ liệu từ ESP32 payload
      // ESP32 gửi: {"event":"motion", "ts":...} hoặc {"sound_level":..., "ts":...}
      
      let type = 'TELEMETRY';
      let action = 'IDLE';
      let confidence = 0;
      
      // Xử lý logic dựa trên nội dung payload
      if (payload.event === 'motion') {
        type = 'DETECTION';
        confidence = 0.8; // PIR motion detected
        action = 'REPULSING'; // Giả định ESP32 sẽ tự kích hoạt đuổi khi có motion
      } else if (payload.event === 'sound_detected') {
        type = 'DETECTION';
        confidence = 0.9; // High sound level detected
        action = 'REPULSING';
      } else if (payload.sound_level !== undefined) {
        type = 'TELEMETRY'; // Periodic report
        confidence = 0;
      }

      const detectionData = {
        deviceId,
        deviceName: deviceInfo.name,
        timestamp: new Date(), // Sử dụng Server Time thay vì payload.ts (millis)
        confidence: confidence,
        location: deviceInfo.location, // Lấy location từ DB
        imageUrl: null,
        action: action,
        method: payload.event === 'sound_detected' ? 'AUDIO' : (payload.event === 'motion' ? 'PIR' : 'NONE'),
        type: type,
        rawPayload: payload // Lưu lại payload gốc để debug nếu cần
      };

      // 1. Save to Firestore
      const docId = await firestoreService.saveDetection(detectionData);
      
      // 2. Send Notification
      // Chỉ gửi thông báo khi là sự kiện phát hiện (motion hoặc sound alert)
      if (type === 'DETECTION') {
        await notificationService.sendDetectionNotification({ ...detectionData, id: docId });
      }

    } catch (error) {
      logger.error('Error processing MQTT message:', error);
    }
  });

  client.on('error', (err) => {
    logger.error('MQTT Connection Error:', err);
  });

  client.on('reconnect', () => {
    logger.info('Reconnecting to MQTT Broker...');
  });
};
