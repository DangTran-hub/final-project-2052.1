#include "actuators.h"
#include "../config.h"
#include "../mqtt/mqtt_client.h"

static bool led_state = false;
static bool buzzer_state = false;
static unsigned long led_until = 0;
static unsigned long buzzer_until = 0;

void actuator_init() {
  pinMode(LED_GATE_PIN, OUTPUT);
  digitalWrite(LED_GATE_PIN, LOW);
}

void actuator_led_set(bool on, uint32_t duration_ms) {
  led_state = on;
  digitalWrite(LED_GATE_PIN, on ? HIGH : LOW);
  if (duration_ms > 0) {
    led_until = millis() + duration_ms;
  } else {
    led_until = 0;
  }
  mqtt_publish_telemetry(String("{\"actuator\":\"led\",\"state\":") + (on ? "1":"0") + "}");
}

void actuator_buzzer_set(bool on, uint32_t duration_ms) {
  buzzer_state = on;
  if (duration_ms > 0) {
    buzzer_until = millis() + duration_ms;
  } else buzzer_until = 0;
  mqtt_publish_telemetry(String("{\"actuator\":\"buzzer\",\"state\":") + (on ? "1":"0") + "}");
}

void actuator_activate_for_motion() {
  // short flash + beep
  actuator_led_set(true, 2000);
  actuator_buzzer_set(true, 1000);
}

void actuator_activate_for_sound() {
  // different pattern
  actuator_led_set(true, 3000);
  actuator_buzzer_set(true, 1500);
}

void actuator_loop() {
  unsigned long now = millis();
  if (led_until && now > led_until) {
    led_until = 0;
    actuator_led_set(false, 0);
  }
  if (buzzer_until && now > buzzer_until) {
    buzzer_until = 0;
    actuator_buzzer_set(false, 0);
  }
}
