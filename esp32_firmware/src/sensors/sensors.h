#pragma once
#include <Arduino.h>

void sensors_init();
void sensors_loop();
int sensors_get_sound_level(); // trả về RMS hoặc độ mạnh âm
void sensors_set_sound_threshold(int v);
