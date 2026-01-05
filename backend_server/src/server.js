import app from './app.js';
import { config } from './config/config.js';
import logger from './utils/logger.js';
import * as mqttService from './services/mqtt.service.js';

const PORT = config.port;

// Start MQTT Service
mqttService.connect();

app.listen(PORT, () => {
  logger.info(`Server is running on port ${PORT} in ${config.env} mode`);
});
