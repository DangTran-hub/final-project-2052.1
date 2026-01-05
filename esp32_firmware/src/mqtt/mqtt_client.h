#pragma once
#include <Arduino.h>

void mqtt_init();
void mqtt_loop();
bool mqtt_connected();
void mqtt_publish_telemetry(const String &payload);
void mqtt_send_status(const String &status);

// Testing helper: publish a fake telemetry packet
void mqtt_publish_fake_packet();
