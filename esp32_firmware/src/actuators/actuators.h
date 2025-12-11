#pragma once
#include <Arduino.h>

void actuator_init();
void actuator_loop();

void actuator_led_set(bool on, uint32_t duration_ms = 0);
void actuator_buzzer_set(bool on, uint32_t duration_ms = 0);

// helper used by sensors to quickly trigger deterrent
void actuator_activate_for_motion();
void actuator_activate_for_sound();
