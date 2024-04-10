#include <Adafruit_NeoPixel.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>

WiFiUDP udp;
IPAddress remoteIP;

#define LED_COUNT  33
#define LED_PIN    D1
#define ANALOG_PIN A0

const char* ssid = "MobinNet79E3";
const char* password = "EFFE79E3";
const int udpPort = 8080;


Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);
float analog_val = 0;

uint8_t red = 255;
uint8_t green = 255;
uint8_t blue = 255;
uint8_t brightness = 10;
uint8_t mode = 0;

unsigned long rainbowLastUpdate = 0;
long rainbowHue = 0;

unsigned long colorWipeLastUpdate = 0;
uint32_t colorWipeColor;
int colorWipeDelay;
bool colorWipeForward = true;
int colorWipePixel = 0;

unsigned long theaterChaseLastUpdate = 0;
uint32_t theaterChaseColor;
int theaterChaseDelay;
int theaterChaseOuterLoop = 0;
int theaterChaseInnerLoop = 0;
int theaterChasePixelOffset = 0;
bool theaterChaseOn = true;

void setup() {
  pinMode(D4,OUTPUT);
  digitalWrite(D4,HIGH);
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  digitalWrite(D4,LOW);
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  udp.begin(udpPort);
  sendConnectionStatus(true); // Send a packet to indicate connection establishment
  strip.begin();
  strip.show();
  strip.setBrightness(10);

}

void loop() {

  int packetSize = udp.parsePacket();
  if (packetSize) {
    remoteIP = udp.remoteIP();
    uint8_t rgbValues[5];
    udp.read(rgbValues, sizeof(rgbValues));

     red = rgbValues[0];
     green = rgbValues[1];
     blue = rgbValues[2];
     brightness = rgbValues[3];
     mode = rgbValues[4];
     strip.setBrightness(brightness);

    Serial.printf("Received RGB values: %d, %d, %d, %d, %d\n", red, green, blue , brightness , mode);
  }
  
  switch (mode) {
    case 0:
      setStripColor(strip.Color(red, green, blue));
      break;
    case 1:
        updateRainbow();
      break;
    case 2:
       colorWipe(strip.Color(red, green, blue), 40);
      break;
    case 3:
       theaterChase(strip.Color(red, green, blue), 100);
      break;
    case 4:
      breathingEffect(strip.Color(red, green, blue), 5000);
      break;
    case 5:
      comet(strip.Color(red, green, blue), 50);
      break;
    case 6:
       theaterChase2(strip.Color(red, green, blue), 100);
      break;
  }

  

}

void sendConnectionStatus(bool connected) {
  uint8_t data = connected ? 1 : 0;
  udp.beginPacket(remoteIP, 8081);
  udp.write(data);
  udp.endPacket();
}

void setStripColor(uint32_t color) {
  for (int i = 0; i <= strip.numPixels(); i++) {
    strip.setPixelColor(i, color);
  }
  strip.show();
}



void updateRainbow() {
  unsigned long currentMillis = millis();
  if (currentMillis - rainbowLastUpdate >= 40) {  // Update every 20 milliseconds
    rainbowLastUpdate = currentMillis;
    rainbowHue += 256;  // Increment the hue value
    for (int i = 0; i < strip.numPixels(); i++) {
      int pixelHue = rainbowHue + (i * 65536L / strip.numPixels());
      strip.setPixelColor(i, strip.gamma32(strip.ColorHSV(pixelHue)));
    }
    strip.show();
  }
}



void colorWipe(uint32_t color, int wait) {
  colorWipeColor = color;
  colorWipeDelay = wait;

  unsigned long currentMillis = millis();
  if (currentMillis - colorWipeLastUpdate >= colorWipeDelay) {
    colorWipeLastUpdate = currentMillis;

    if (colorWipeForward) {
      strip.setPixelColor(colorWipePixel, colorWipeColor);
      colorWipePixel++;
      if (colorWipePixel >= strip.numPixels()) {
        colorWipeForward = false;
        colorWipePixel = strip.numPixels() - 1;
      }
    } else {
      strip.setPixelColor(colorWipePixel, strip.Color(0, 0, 0));
      colorWipePixel--;
      if (colorWipePixel < 0) {
        colorWipeForward = true;
        colorWipePixel = 0;
      }
    }

    strip.show();
  }
}



void theaterChase(uint32_t color, int wait) {
  theaterChaseColor = color;
  theaterChaseDelay = wait;

  unsigned long currentMillis = millis();
  if (currentMillis - theaterChaseLastUpdate >= theaterChaseDelay) {
    theaterChaseLastUpdate = currentMillis;

    if (theaterChaseOn) {
      for (int i = 0; i < strip.numPixels(); i += 3) {
        strip.setPixelColor(i + theaterChasePixelOffset, theaterChaseColor);
      }
    } else {
      for (int i = 0; i < strip.numPixels(); i += 3) {
        strip.setPixelColor(i + theaterChasePixelOffset, strip.Color(0, 0, 0));
      }
    }

    strip.show();

    theaterChasePixelOffset++;
    if (theaterChasePixelOffset >= 3) {
      theaterChasePixelOffset = 0;
      theaterChaseOn = !theaterChaseOn;
      theaterChaseInnerLoop++;
      if (theaterChaseInnerLoop >= 3) {
        theaterChaseInnerLoop = 0;
        theaterChaseOuterLoop++;
        if (theaterChaseOuterLoop >= 10) {
          theaterChaseOuterLoop = 0;
        }
      }
    }
  }
}

void runningLights(uint32_t color, int wait) {
  int position = 0;
  for (int i = 0; i < strip.numPixels() * 2; i++) {
    position = i % strip.numPixels();
    setStripColor(strip.Color(
        (255 / strip.numPixels()) * position,
        (255 / strip.numPixels()) * position,
        0));
    delay(wait);
  }
}

void comet(uint32_t color, int wait) {
  for (int i = 0; i < strip.numPixels() * 2; i++) {
    strip.setPixelColor(i % strip.numPixels(), color);
    strip.show();
    delay(wait);
    strip.setPixelColor(i % strip.numPixels(), 0);
  }
}

void theaterChase2(uint32_t color, int wait) {
  for (int j = 0; j < 10; j++) {  // Repeat the chase 10 times
    for (int q = 0; q < 3; q++) {
      for (int i = 0; i < strip.numPixels(); i = i + 3) {
        strip.setPixelColor(i + q, color);  // Turn on every third pixel
      }
      strip.show();
      delay(wait);

      for (int i = 0; i < strip.numPixels(); i = i + 3) {
        strip.setPixelColor(i + q, 0);  // Turn off every third pixel
      }
    }
  }
}

void breathingEffect(uint32_t color, int cycleDuration) {
  int steps = 100;  // Number of steps in the breathing cycle
  int delayTime = cycleDuration / (2 * steps);  // Delay time for each step

  for (int i = 0; i <= steps; i++) {
    float factor = sin((float)i / steps * PI);  // Calculate a sine factor for smooth breathing
    uint8_t red = (uint8_t)((color >> 16) * factor);
    uint8_t green = (uint8_t)(((color >> 8) & 0xFF) * factor);
    uint8_t blue = (uint8_t)((color & 0xFF) * factor);

    setStripColor(strip.Color(red, green, blue));
    delay(delayTime);
  }

  // Reverse the breathing effect
  for (int i = steps; i >= 0; i--) {
    float factor = sin((float)i / steps * PI);
    uint8_t red = (uint8_t)((color >> 16) * factor);
    uint8_t green = (uint8_t)(((color >> 8) & 0xFF) * factor);
    uint8_t blue = (uint8_t)((color & 0xFF) * factor);

    setStripColor(strip.Color(red, green, blue));
    delay(delayTime);
  }
}
