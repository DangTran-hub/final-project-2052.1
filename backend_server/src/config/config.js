import dotenv from 'dotenv';
dotenv.config();

export const config = {
  port: process.env.PORT || 3000,
  env: process.env.NODE_ENV || 'development',
  logLevel: process.env.LOG_LEVEL || 'info',
  mqtt: {
    brokerUrl: process.env.MQTT_BROKER,
    username: process.env.MQTT_USER,
    password: process.env.MQTT_PASSWORD,
    topicPattern: process.env.MQTT_TOPIC_PATTERN || 'iot/rodent/+/telemetry',
  },
  firebase: {
    credentialPath: process.env.GOOGLE_APPLICATION_CREDENTIALS || './src/google-application-credentials.json',
    collection: process.env.FIRESTORE_COLLECTION || 'detections',
  }
};