#include "wifi.h"
#include "../secrets.h"
#include <WiFi.h>

static void wifiEvent(WiFiEvent_t event) {
  // có thể logging thêm
  switch (event) {
        case SYSTEM_EVENT_STA_CONNECTED:
            Serial.println("[WiFi] Connected to AP");
            break;

        case SYSTEM_EVENT_STA_GOT_IP:
            Serial.print("[WiFi] Got IP: ");
            Serial.println(WiFi.localIP());
            break;

        case SYSTEM_EVENT_STA_DISCONNECTED:
            Serial.println("[WiFi] Disconnected. Reconnecting...");
            WiFi.reconnect();
            break;

        default:
            break;
    }
}

void wifi_init() {
  WiFi.disconnect(true);  
  WiFi.mode(WIFI_STA);
  WiFi.onEvent(wifiEvent);
  Serial.printf("WiFi: connecting to %s ...\n", WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
}

bool wifi_connected() {
  return WiFi.status() == WL_CONNECTED;
}

void wifi_reconnect() {
    if (WiFi.status() != WL_CONNECTED) {
        WiFi.disconnect();
        WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    }
}

