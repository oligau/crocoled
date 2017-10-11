// Arduino Yun listens to python script via Bridge library to turn digital pins on/off.
// H.Zimmerman, 9-12-2014.
// Arduino Yun.

#include <Adafruit_NeoPixel.h>

#include <Bridge.h>
#include <stdio.h>

#define STATUS_LED_PIN 13

#define PIXELS_PIN 6

// How many NeoPixels are attached to the Arduino?
#define NUM_LEDS 2

#define BRIGHTNESS 100

#define REFRESH_RATE 15

 
// Here we will hold the values coming from Python via Bridge.
#define FRAME_BUFFER_SIZE NUM_LEDS*3 
// char frameBuffer[FRAME_BUFFER_SIZE]; 
char frameBuffer[1000]; 

// Frame counter
int frameCount;

// When we setup the NeoPixel library, we tell it how many pixels, and which pin to use to send signals.
// Note that for older NeoPixel strips you might need to change the third parameter--see the strandtest
// example for more information on possible values.
Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUM_LEDS, PIXELS_PIN, NEO_GRB + NEO_KHZ800);
 
void setup() {

  // Zero out the memory we're using for the Bridge.
  memset(frameBuffer, 0, 2);
   
  // Initialize digital pin 13 as output for heartbeat LED.
  pinMode(STATUS_LED_PIN, OUTPUT); 
  digitalWrite(STATUS_LED_PIN, LOW);
 
  // Start using the Bridge.
  Bridge.begin();

  // Start console debug serial output.
  Console.begin();

  while (!Console) {
    ; // wait for Console port to connect.
  }

  Console.println("Crocoled Arduino Bridge started");

  pixels.begin(); // This initializes the NeoPixel library.  
 
}

void receiveFrame() {
  Console.println("receiveFrame() enter");
  
  int byteRead = Bridge.get("frame", frameBuffer, FRAME_BUFFER_SIZE);
  Console.print("receiveFrame() Bridge.get read bytes: ");
  Console.println(byteRead);

  Console.print("frameBuffer: ");
  Console.println(frameBuffer);
  
  Console.println("receiveFrame() done");
  
}

void drawFrame() {

  for(int i=0;i<NUM_LEDS;i++){

    // pixels.Color takes RGB values, from 0,0,0 up to 255,255,255
    pixels.setPixelColor(i, pixels.Color(0,150,0)); // Moderately bright green color.

  }

  pixels.show(); // This sends the updated pixel color to the hardware.

  
}
 
void loop() {

   Console.println("loop() start");

  // Flash LED13 each time we draw a frame to indicate hearbeat. 
  // Turn on status LED before drawing, then we'll turn it off after we're done with this frame.
  digitalWrite(STATUS_LED_PIN, HIGH);

  receiveFrame();

  drawFrame();
  
  
//  // Write current value of D12 to the pin (basically turning it on or off).
//  Bridge.get("D12", D12value, 2);
//  int D12int = atoi(D12value);
//  digitalWrite(12, D12int);
//   
//  // An arbitrary amount of delay to make the whole thing more reliable. YMMV
//  delay(10);
//   
//  // Write current value of D13 to the pin (basically turning it on or off).
//  Bridge.get("D13", D13value, 2);
//  int D13int = atoi(D13value);
//  digitalWrite(13, D13int);
//   
//  // An arbitrary amount of delay to make the whole thing more reliable. YMMV
//  delay(10);  

//  for(int i=0;i<NUM_LEDS;i++){
//
//    // pixels.Color takes RGB values, from 0,0,0 up to 255,255,255
//    pixels.setPixelColor(i, pixels.Color(0,150,0)); // Moderately bright green color.
//
//    pixels.show(); // This sends the updated pixel color to the hardware.
//
//    delay(50); // Delay for a period of time (in milliseconds).
//
//  }
  
  // Wait refresh rate.
  delay(1000/REFRESH_RATE);
  
  // Turn off status LED to indicate we're done drawing frame.
  digitalWrite(STATUS_LED_PIN, LOW);

  // Output the frame counter
  Console.println("loop() done");


}
