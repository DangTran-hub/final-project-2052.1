# ESP32 Rodent-Deterrent Node

Small ESP32-based firmware for a rodent deterrent device. It detects motion (PIR) and sound (INMP441 via I2S), publishes telemetry over MQTT, and triggers actuators (LED & buzzer). Built with PlatformIO for Arduino/ESP32.

## Hardware
- ESP32 development board
- PIR motion sensor (e.g., AM312) connected to `PIR_PIN` pin
- INMP441 I2S microphone connected to `I2S_SCK_PIN`, `I2S_WS_PIN`, `I2S_SD_PIN`
- LED strip / MOSFET gate connected to `LED_GATE_PIN` (controls LED deterrent)
- (Optional) Buzzer hardware: not wired by default — buzzer is controlled in code but no pin is defined in `config.h`.

Pin mapping can be reviewed and changed in `src/config.h`.

## Project structure
- `src/main.cpp` - setup and main loop
- `src/wifi/` - WiFi initialization and reconnect logic
- `src/mqtt/` - MQTT client and command handling
- `src/sensors/` - PIR and I2S mic logic (sound RMS, periodic telemetry)
- `src/actuators/` - LED/buzzer handlers, patterns
- `src/config.h` - pin mappings, thresholds, timing, topics
- `src/secrets.h` - WiFi and MQTT credentials (you must edit this)
- `src/certificate.h` - TLS root CA for secure MQTT connections

## Configuration
1. Edit `src/secrets.h` and set your WiFi and MQTT broker credentials:
   - `WIFI_SSID`, `WIFI_PASSWORD`
   - `MQTT_BROKER`, `MQTT_PORT`, `MQTT_USER`, `MQTT_PASSWORD`
2. (Optional) Edit `src/config.h` to change `DEVICE_ID`, topic names, thresholds, or pin mappings.
3. TLS CA certificate is in `src/certificate.h`. Replace if your broker requires a different CA or if you use a self-signed cert.

## Building and flashing
This project uses PlatformIO. From the project root run:

```bash
pio run          # build
pio run -t upload  # build and upload to device
pio device monitor  # open serial monitor
```

Alternatively use the PlatformIO extension in VS Code.

## MQTT Topics
Topics are defined in `src/config.h` based on `DEVICE_ID`:
- Telemetry: `MQTT_TELEMETRY_TOPIC` (default `iot/rodent/<DEVICE_ID>/telemetry`)
- Commands: `MQTT_CMD_TOPIC` (default `iot/rodent/<DEVICE_ID>/cmd`)
- Status: `MQTT_STATUS_TOPIC` (default `iot/rodent/<DEVICE_ID>/status`)

Make sure your client subscribes and publishes to the correct topics. The firmware sends a retained status message (online/offline) and publishes telemetry for motion and sound.

## Testing with EMQX (example using mosquitto client)
EMQX (including EMQX Cloud) is the MQTT broker used in this project. The firmware uses TLS with a CA certificate defined in `src/certificate.h`.

Save the certificate content from `src/certificate.h` into a file called `emqx_ca.pem` and use it with your MQTT client.

Subscribe to telemetry and status (TLS/port 8883 example):

```bash
mosquitto_sub -h <MQTT_HOST> -p 8883 -u <MQTT_USER> -P <MQTT_PASSWORD> --cafile ./emqx_ca.pem -t "iot/rodent/esp32_node_01/#" -v
```

Publish commands to the device command topic (replace `esp32_node_01` with your `DEVICE_ID`):

```bash
# Turn LED on for 5 seconds
mosquitto_pub -h <MQTT_HOST> -p 8883 -u <MQTT_USER> -P <MQTT_PASSWORD> --cafile ./emqx_ca.pem -t "iot/rodent/esp32_node_01/cmd" -m '{"cmd":"led_on","duration_ms":5000}'

# Turn LED off
mosquitto_pub -h <MQTT_HOST> -p 8883 -u <MQTT_USER> -P <MQTT_PASSWORD> --cafile ./emqx_ca.pem -t "iot/rodent/esp32_node_01/cmd" -m '{"cmd":"led_off"}'

# Query status
mosquitto_pub -h <MQTT_HOST> -p 8883 -u <MQTT_USER> -P <MQTT_PASSWORD> --cafile ./emqx_ca.pem -t "iot/rodent/esp32_node_01/cmd" -m '{"cmd":"get_status"}'

# Set sound threshold
mosquitto_pub -h <MQTT_HOST> -p 8883 -u <MQTT_USER> -P <MQTT_PASSWORD> --cafile ./emqx_ca.pem -t "iot/rodent/esp32_node_01/cmd" -m '{"cmd":"set_sound_threshold","value":1500}'
```

Adjust `MQTT_HOST`, `MQTT_PORT` (or use 8883 for TLS), and credentials. For EMQX Cloud, set your EMQX Cloud endpoint as `MQTT_HOST`. If you want to skip certificate verification while testing, you can use `--insecure` with mosquitto tools, but this is not recommended for production.

## Verifying device
- `Serial Monitor` shows WiFi, MQTT connect logs, and telemetry messages. Use `pio device monitor` or your serial terminal at 115200 baud.
- When motion is detected, the firmware publishes a `motion` event and triggers deterrent actions if configured.
- Sound level pushes every `SOUND_PUBLISH_INTERVAL_MS` and triggers an alert when above threshold.

## Troubleshooting
- No serial output: verify correct USB/COM port and board selection.
- WiFi issues: check `secrets.h` credentials and `SSID` visibility.
- MQTT TLS: confirm broker certificate chain matches `src/certificate.h` or update it.
- Topics don't match: ensure your MQTT client subscribes to `iot/rodent/<DEVICE_ID>/#` or the specific topics defined in `config.h`.

## Notes and next steps
- Buzzer pin is not defined in `config.h`. Implement a buzzer pin and hardware driver if you want audible feedback.
- The command topic previously used a hard-coded `devices/<ID>/command` topic; code now uses `MQTT_CMD_TOPIC` macro for consistency.

If you want, I can:
- Add a buzzer pin and implementation in `actuators/actuators.cpp`.
- Add OTA for remote firmware updates.
- Improve telemetry to include device stats (RSSI, memory usage).

---

Created by the project assistant for setup and testing guidance.
