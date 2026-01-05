// File này setup các thông số cho thiết bị bao gồm:
//  - Pin Mapping
//  - Thresholds vs Timming
//  - MQTT Topics

#pragma once

// pin mapping
#define I2S_SCK_PIN   26   // Bit Clock
#define I2S_WS_PIN    25   // Word Select (L/R)
#define I2S_SD_PIN    32   // Serial Data (DOUT)

#define PIR_PIN       14   // AM312 output pin (digital)
#define LED_GATE_PIN  27   // MOSFET gate to drive 5V LED strip

#define DEVICE_ID     "esp32_node_01"

// thresholds and timings
#define SOUND_PUBLISH_INTERVAL_MS 2000
#define MOTION_DEBOUNCE_MS 700
#define SOUND_RMS_WINDOW_MS 200
#define DEFAULT_SOUND_THRESHOLD 1000

// MQTT topics
#define MQTT_BASE_TOPIC         "iot/rodent/" DEVICE_ID
#define MQTT_TELEMETRY_TOPIC    MQTT_BASE_TOPIC "/telemetry"
#define MQTT_CMD_TOPIC          MQTT_BASE_TOPIC "/cmd"
#define MQTT_STATUS_TOPIC       MQTT_BASE_TOPIC "/status"

// Testing: enable periodic fake telemetry publish (set to 0 to disable)
#define ENABLE_FAKE_PUBLISH 0
#define FAKE_PUBLISH_INTERVAL_MS 10000  // 10 seconds
