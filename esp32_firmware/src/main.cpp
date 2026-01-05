#include <Arduino.h>
#include "config.h"
#include "secrets.h"
#include "wifi/wifi.h"
#include "mqtt/mqtt_client.h"
#include "sensors/sensors.h"
#include "actuators/actuators.h"
//#include "ota/ota.h"

unsigned long last_wifi_check = 0;
unsigned long wifi_retry_interval = 5000;   // 5 giây

void setup() {
  Serial.begin(115200);
  delay(100);
  Serial.println("Starting rodent-deterrent node...");
  sensors_init();
  actuator_init();
  wifi_init();
  mqtt_init();
  //ota_init();
}

void loop() {
  if (!wifi_connected()) {
    unsigned long now = millis();
    // Check mỗi 5 giây
    if (now - last_wifi_check > wifi_retry_interval) {
      Serial.println("[WiFi] Not connected. Retrying...");
      wifi_reconnect();           // Hàm bạn sẽ tạo trong wifi.cpp
      last_wifi_check = now;
    }
  } else {
    mqtt_loop();

#if ENABLE_FAKE_PUBLISH
    static unsigned long lastFakePublish = 0;
    unsigned long now = millis();
    if (now - lastFakePublish > FAKE_PUBLISH_INTERVAL_MS) {
      if (mqtt_connected()) {
        mqtt_publish_fake_packet();
      }
      lastFakePublish = now;
    }
#endif
  }
  sensors_loop();
  actuator_loop();
  //ArduinoOTA.handle();
  delay(10);
}

