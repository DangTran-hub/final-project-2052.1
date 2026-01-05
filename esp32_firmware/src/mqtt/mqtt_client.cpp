#include "mqtt_client.h"
#include "../secrets.h"
#include "../config.h"
#include "../certificate.h"
#include <WiFiClientSecure.h>
#include <PubSubClient.h>

static WiFiClientSecure espClientSecure;
static PubSubClient client(espClientSecure);

static void handleCommand(char* topic, byte* payload, unsigned int length);

void mqtt_init() {
  espClientSecure.setCACert(EMQX_CA_CERTIFICATE);
  client.setServer(MQTT_BROKER, MQTT_PORT);
  client.setCallback(handleCommand);
}

bool mqtt_connected() {
  return client.connected();
}

static void mqtt_reconnect_if_needed() {
  if (client.connected()) return;
  static unsigned long lastAttempt = 0;
  if (millis() - lastAttempt < 5000) return;
  lastAttempt = millis();
  Serial.println("MQTT: connecting...");
  String clientId = String(DEVICE_ID) + "-" + String(random(0xffff), HEX);
  // if (client.connect(clientId.c_str(), MQTT_USER, MQTT_PASSWORD)) {
  //   Serial.println("MQTT: connected");
  //   client.subscribe(MQTT_CMD_TOPIC);
  //   // send initial status
  //   mqtt_send_status("online");
  // } else {
  //   Serial.printf("MQTT: failed rc=%d\n", client.state());
  // }

  String willPayload = "{\"device\":\"" DEVICE_ID "\",\"status\":\"offline\"}";
  bool ok = client.connect(
      clientId.c_str(),
      MQTT_USER,
      MQTT_PASSWORD,
      MQTT_STATUS_TOPIC,
      1,
      true,
      willPayload.c_str()
  );

  if (ok) {
    Serial.println("MQTT: connected");

    // Subscribe to command topic from config.h
    client.subscribe(MQTT_CMD_TOPIC, 1);
    // Send initial status
    mqtt_send_status("online");
  } else {
    Serial.printf("MQTT: failed rc=%d\n", client.state());
  }
}

void mqtt_loop() {
  mqtt_reconnect_if_needed();
  if (client.connected()) {
    client.loop();
  }
}

void mqtt_publish_telemetry(const String &payload) {
  if (client.connected()) {
    client.publish(MQTT_TELEMETRY_TOPIC, payload.c_str());
  }
}

void mqtt_send_status(const String &status) {
  if (client.connected()) {
    String m = "{\"device\":\"" DEVICE_ID "\",\"status\":\"" + status + "\"}";
    client.publish(MQTT_STATUS_TOPIC, m.c_str(), true); // retained
  }
}

// Testing: publish a fake telemetry packet to the telemetry topic
void mqtt_publish_fake_packet() {
  if (!client.connected()) return;
  // Create a simple fake telemetry JSON payload
  String payload = "{\"device\":\"" DEVICE_ID "\",\"ts\":" + String(millis()) + ",\"type\":\"telemetry\",\"battery\":92,\"motion\":false,\"sound_level\":" + String(random(10,100)) + "}";
  client.publish(MQTT_TELEMETRY_TOPIC, payload.c_str());
  Serial.printf("MQTT: sent fake packet: %s\n", payload.c_str());
}

/* Command payloads (JSON) e.g.
{
  "cmd": "led_on",
  "duration_ms": 5000
}
*/
#include <ArduinoJson.h>
void handleCommand(char* topic, byte* payload, unsigned int length) {
  Serial.printf("MQTT: got msg on %s\n", topic);
  JsonDocument doc;
  DeserializationError err = deserializeJson(doc, payload, length);
  if (err) {
    Serial.println("MQTT: invalid json");
    return;
  }
  const char *cmd = doc["cmd"];
  if (!cmd) return;
  String s = String(cmd);
  if (s == "led_on") {
    int dur = doc["duration_ms"] | 0;
    // publish event to actuator (use external function via extern)
    extern void actuator_led_set(bool on, uint32_t duration_ms);
    actuator_led_set(true, dur);
  } else if (s == "led_off") {
    extern void actuator_led_set(bool on, uint32_t duration_ms);
    actuator_led_set(false, 0);
  } else if (s == "siren_on") {
    int dur = doc["duration_ms"] | 0;
    extern void actuator_buzzer_set(bool on, uint32_t duration_ms);
    actuator_buzzer_set(true, dur);
  } else if (s == "siren_off") {
    extern void actuator_buzzer_set(bool on, uint32_t duration_ms);
    actuator_buzzer_set(false, 0);
  } else if (s == "get_status") {
    mqtt_send_status("online");
  } else if (s == String("set_sound_threshold")) {
    int thr = doc["value"] | DEFAULT_SOUND_THRESHOLD;
    extern void sensors_set_sound_threshold(int v);
    sensors_set_sound_threshold(thr);
    mqtt_send_status(String("sound_thr_set:") + String(thr));
  }
}
