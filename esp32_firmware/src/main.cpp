#include <Arduino.h>

#define BUTTON_PIN 16
#define LED_PIN 17

void setup() {
  Serial.begin(9600);
  pinMode(BUTTON_PIN, INPUT_PULLDOWN);  // Dùng điện trở kéo xuống nội bộ
  pinMode(LED_PIN, OUTPUT);
}

void loop() {
  if (digitalRead(BUTTON_PIN) == HIGH) { // Khi nhấn
    Serial.println("LED ON");
    digitalWrite(LED_PIN, HIGH);
  } else {
    Serial.println("LED OFF");
    digitalWrite(LED_PIN, LOW);
  }
}
