#include "sensors.h"
#include "../config.h"
#include "../mqtt/mqtt_client.h"
#include <driver/i2s.h>

static volatile bool motion_flag = false;
static unsigned long last_motion_ms = 0;
static int sound_threshold = DEFAULT_SOUND_THRESHOLD;
static unsigned long last_sound_publish = 0;

static void IRAM_ATTR pir_isr() {
  unsigned long now = millis();
  if (now - last_motion_ms < MOTION_DEBOUNCE_MS) return;
  last_motion_ms = now;
  motion_flag = true;
}

// Simple I2S config for INMP441
static const i2s_port_t I2S_PORT = I2S_NUM_0;
static void i2s_init_for_inmp441() {
  i2s_config_t i2s_config = {
    .mode = i2s_mode_t(I2S_MODE_MASTER | I2S_MODE_RX),
    .sample_rate = 16000,
    .bits_per_sample = I2S_BITS_PER_SAMPLE_32BIT,
    .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
    .communication_format = i2s_comm_format_t(I2S_COMM_FORMAT_STAND_I2S),
    .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1,
    .dma_buf_count = 4,
    .dma_buf_len = 256,
    .use_apll = false,
    .tx_desc_auto_clear = false,
    .fixed_mclk = 0
  };
  i2s_pin_config_t pin_config = {
    .bck_io_num = I2S_SCK_PIN,
    .ws_io_num = I2S_WS_PIN,
    .data_out_num = I2S_PIN_NO_CHANGE,
    .data_in_num = I2S_SD_PIN
  };
  i2s_driver_install(I2S_PORT, &i2s_config, 0, NULL);
  i2s_set_pin(I2S_PORT, &pin_config);
  i2s_zero_dma_buffer(I2S_PORT);
}

void sensors_init() {
  pinMode(PIR_PIN, INPUT);
  attachInterrupt(digitalPinToInterrupt(PIR_PIN), pir_isr, RISING);
  i2s_init_for_inmp441();
  last_sound_publish = millis();
}

int sensors_get_sound_level() {
  // read small buffer from I2S and compute RMS
  const int buf_samples = 256;
  uint8_t i2s_read_buf[buf_samples * 4];
  size_t bytes_read = 0;
  i2s_read(I2S_PORT, i2s_read_buf, sizeof(i2s_read_buf), &bytes_read, 10 / portTICK_PERIOD_MS);
  if (bytes_read == 0) return 0;
  // each sample 32-bit, left-aligned signed 24-bit typically
  int32_t *samples = (int32_t*)i2s_read_buf;
  int sample_count = bytes_read / 4;
  if(sample_count <= 0) return 0;
  double sumsq = 0;
  for (int i = 0; i < sample_count; ++i) {
    int32_t s = samples[i] >> 8; // shift to 24->16 bits
    sumsq += (double)s * (double)s;
  }
  double rms = sqrt(sumsq / sample_count);
  return (int)rms;
}

void sensors_set_sound_threshold(int v) {
  sound_threshold = v;
}

void sensors_loop() {
  // motion detection
  if (motion_flag) {
    motion_flag = false;
    // publish motion event
    String msg = "{\"event\":\"motion\",\"ts\":" + String(millis()) + "}";
    mqtt_publish_telemetry(msg);
    // optionally auto-activate deterrent
    extern void actuator_activate_for_motion();
    actuator_activate_for_motion();
  }

  // sound detection and periodic publish
  if (millis() - last_sound_publish > SOUND_PUBLISH_INTERVAL_MS) {
    int level = sensors_get_sound_level();
    String msg = String("{\"sound_level\":") + String(level) + ",\"ts\":" + String(millis()) + "}";
    mqtt_publish_telemetry(msg);
    last_sound_publish = millis();
    // if above threshold -> action
    if (level > sound_threshold) {
      String alert = "{\"event\":\"sound_detected\",\"level\":" + String(level) + ",\"ts\":" + String(millis()) + "}";
      mqtt_publish_telemetry(alert);
      extern void actuator_activate_for_sound();
      actuator_activate_for_sound();
    }
  }
}
