#include <Arduino.h>

const int heartRatePin = 36; // Pin 36 for heart rate sensor

void setup() {
  Serial.begin(115200); // Start serial communication
}

void loop() {
  // Read heart rate sensor data
  int heartRate = analogRead(heartRatePin);
  
  // Send heart rate data over serial
  Serial.println(heartRate);

  delay(1000); // Adjust as needed based on sensor and application requirements
}