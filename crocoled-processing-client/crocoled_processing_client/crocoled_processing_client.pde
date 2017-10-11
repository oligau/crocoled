/**
 * oscP5message by andreas schlegel
 * example shows how to create osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 import processing.video.*;
import oscP5.*;
import netP5.*;


Capture video;
OscP5 oscP5;
NetAddress myRemoteLocation;

/****** Variable de dimension **********/

int Lpan = 14;  // Nb de LED sur la largeur
int Hpan = 14;  // Nb de LED sur la hauteur
int Lvid, Hvid;
float TpalierL, TpalierH;

/********** Variable d'heure et de couleur **********/

float FacHue = 0;
float Time = 0;

/********** Tableau des images **********/

ArrayList frames = new ArrayList();

/* stockage de l'image à envoyer par OSC, 224 * 3 = 672 */
int[] frameBuffer = new int[672];

void setup() {
  size(640,480);
  Lvid = width;
  Hvid = height;
  TpalierL = Lvid/Lpan;
  TpalierH = Hvid/Hpan;
  
  video = new Capture(this, Lvid, Hvid);
  video.start();
  frameRate(15);
  
  oscP5 = new OscP5(this,10023);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("192.168.241.1",10023);
}

void captureEvent(Capture video)
{
  video.read();
  
  PImage img = createImage(Lvid,Hvid,RGB);
  video.loadPixels();
  arrayCopy(video.pixels, img.pixels);
  
  frames.add(img);          // Stockage des images
  if (frames.size() > height/4) 
  {
    frames.remove(0);
  }
}

void draw() {
  //Variable d'heure et couleur correspondante 
  Time = (second() / 10) + (minute() / 2) + (hour() * 10);
  FacHue = (Time * 100) / 265.4;
  
  loadPixels();
  
  // Changement des couleurs
  for (int x = 1; x < Lvid; x += 1)                          
  {
    for (int y = 1; y < Hvid; y += 1)
    {
      colorMode(HSB, 100.0);
      float h = abs(FacHue - hue(video.pixels[y * Lvid + x]));
      float s = saturation(video.pixels[y * Lvid + x]);
      float b = brightness(video.pixels[y * Lvid + x]);
      
      pixels[y * Lvid + x] = color(h, 80, b * 1.5);
      colorMode(RGB, 255);
    }
  }
 
  updatePixels();
  Affichage();
  
}

void AffichageOSC()
{
   /* in the following different ways of creating osc messages are shown by example */
  OscMessage myMessage = new OscMessage("/crocoled/drawFrame");
  
  myMessage.add(new int[] {255,0,0,0,255,0}); /* add an int array to the osc message */
  
  /* ? myMessage.add( frameBuffer); */

  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);  
}

/********** Affichage sur panneau LED **********/

void Affichage()
{
  loadPixels();  
  // Begin loop for columns  
  for (float i = 1; i <= Lvid; i = i + TpalierL) {
      int x = int(i);
    // Begin loop for rows    
    for (float j = 1; j <= Hvid; j = j + TpalierH) {
      int y = int(j);
      int NumPixel = y * Lvid + x;
      println("i = "+i+"  -  j = "+j+"  -  NumPixel = "+NumPixel);
      color c = pixels[NumPixel];
      
      // récupératon RVB
      float RedValue = red(c);
      float BlueValue = blue(c);
      float GreenValue = green(c);
      println("red = "+RedValue+"  -  green = "+GreenValue+"  -  blue = "+BlueValue);
      fill(c);   
      stroke(0);      
      rect(x, y, TpalierL, TpalierH);    
    }  
  }
  
  AffichageOSC();
  
}

/********** Interraction Cube **********/

void keyPressed() {
  println(FacHue);
  
  if (key == 'n') {
    // Variable lié à l'heure
   //Time = second()/2 + minute() + hour() * 10;
   //FacHue = (Time * 100) / 318.5;
   
   Time = (second() / 10) + (minute() / 2) + (hour() * 10);
   FacHue = (Time * 100) / 265.4;
   
   colorMode(HSB, 100.0);
   fill(FacHue,100,100);
   rect(0,0,width, height);
   colorMode(RGB, 255);
  }
}