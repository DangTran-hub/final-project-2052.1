#include <Arduino.h>
#include "config.h"
#include "secrets.h"
#include "wifi/wifi.h"
#include "mqtt/mqtt_client.h"
#include "sensors/sensors.h"
#include "actuators/actuators.h"
//#include "ota/ota.h"

void setup() {
  Serial.begin(115200);
  delay(100);
  Serial.println("Starting rodent-deterrent node...");
  wifi_init();
  mqtt_init();
  sensors_init();
  actuator_init();
  //ota_init();
}

void loop() {
  if (!wifi_connected()) {
    // try reconnecting implicitly via wifi library
  } else {
    mqtt_loop();
  }
  sensors_loop();
  actuator_loop();
  //ArduinoOTA.handle();
  delay(10);
}

