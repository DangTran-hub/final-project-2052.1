#include "wifi.h"
#include "../secrets.h"
#include <WiFi.h>

static void wifiEvent(WiFiEvent_t event) {
  // có thể logging thêm
}

void wifi_init() {
  WiFi.disconnect(true);
  WiFi.onEvent(wifiEvent);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.printf("WiFi: connecting to %s ...\n", WIFI_SSID);
}

bool wifi_connected() {
  return WiFi.status() == WL_CONNECTED;
}
