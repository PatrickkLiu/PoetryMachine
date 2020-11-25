
///A visual peotry machine you could talk to. 
///By Pinyao Liu.

/** Setup: 
 *(may take a while to download library,there's 
 * also a demo recording in the zip folder)
 
 - Installthe WebSockets Library 
 - Run this Sketch
 - Open this link in Chrome web browser: https://codepen.io/getflourish/pen/NpBGqe?editors=1112
 - Transcribed speechrecognition results will be printed to the console.
 
 */

/**
 * Drawing tool for poets. Speak and create.
 * 
 * MOUSE
 * drag                : chaos
 * 
 * KEYS
 * del, backspace      : clear screen
 * s                   : save png
 
 */




/**
 *Credit: 
 *
 * "typo" by Alek & Co https://www.openprocessing.org/sketch/425380
 * Speech recognition component by Florian Schulz https://florianschulz.info/stt/
 * WebSocket Library
 
 */


import processing.video.*;
import processing.sound.*;
import websockets.*;
WebsocketServer socket;
PFont Garamond;
String letters = "It goes like this: ";
JSONObject  afinn;
String textinput ;
Poem p1;

///*sound component
SoundFile e1, e2, e3, e4, e5;


///*video component
// Variable for capture device
Capture video;
// Previous Frame
PImage prevFrame;

// How different must a pixel be to be a "motion" pixel
float threshold = 25;

float trackX = 0;
float trackY = 0;
float smoothedX = 0;
float smoothedY = 0;




void setup() {
  socket = new WebsocketServer(this, 1337, "/p5websocket");
  size(780, 780);
  background(255);
  smooth();

  Garamond=createFont("Garamond.ttf", 32); // load font
  //RobotoMono = createFont("RobotoMono-Regular.ttf", 32);
  //Palatinolino = createFont("Palatino-lino.ttf", 32);

  p1 = new Poem(Garamond, 5, 0); // create new visual poem


  ///*sound component
  afinn = loadJSONObject("afinn111.json"); // load sentiment analysis json object
  e1 = new SoundFile(this, "e1.mp3");
  e2 = new SoundFile(this, "e2.mp3");
  e3 = new SoundFile(this, "e3.mp3");
  e4 = new SoundFile(this, "e4.mp3");
  e5 = new SoundFile(this, "e5.mp3");

  ///*video component
  // Using the default capture device
  video = new Capture(this, width, height);
  video.start();

  // Create an empty image the same size as the video
  prevFrame = createImage(video.width, video.height, RGB);
}


// New frame available from camera
void captureEvent(Capture video) {
  // Save previous frame for motion detection!!
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  prevFrame.updatePixels();  
  video.read();
}


void draw() {
  p1.drawPoem();

  ///*video component
  // You don't need to display it to analyze it!
  //image(video, 0, 0);



  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();


  // These are the variables we'll need to find the average X and Y
  float sumX = 0;
  float sumY = 0;
  int motionCount = 0; 
  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      // What is the current color
      color current = video.pixels[x+y*video.width];

      // What is the previous color
      color previous = prevFrame.pixels[x+y*video.width];

      // Step 4, compare colors (previous vs. current)
      float r1 = red(current); 
      float g1 = green(current);
      float b1 = blue(current);
      float r2 = red(previous); 
      float g2 = green(previous);
      float b2 = blue(previous);

      // Motion for an individual pixel is the difference between the previous color and current color.
      float diff = dist(r1, g1, b1, r2, g2, b2);

      // If it's a motion pixel add up the x's and the y's
      if (diff > threshold) {
        sumX += x;
        sumY += y;
        motionCount++;
      }
    }
  }

  // average location is total location divided by the number of motion pixels.
  Float avgX = sumX / motionCount; 
  Float avgY = sumY / motionCount; 
  //print(avgX,avgY);
  if (( Float.isNaN(avgX)) || Float.isNaN(avgY)) {
    trackX = width/2;
    trackY = height/2;
    print("not a number");
  } else {  
    trackX = map(avgX, 100, 500, 0, 780);
    trackY = map(avgY, 300, 650, 0, 780);
  }


  smoothedX = lerp(smoothedX, trackX, 0.2);
  smoothedY = lerp(smoothedY, trackY, 0.2);


  // Draw a circle based on average motion
  /*
  smooth();
   noStroke();
   fill(0);
   ellipse(avgX, avgY, 16, 16);
   */
}


void webSocketServerEvent(String msg) {
  letters += msg;
  //println(msg);
  String[] words = msg.split(" ");
  println(words);


  float[] scoredwords;
  int totalScore = 0;
  for (int i = 0; i < words.length; i++) {
    String word = words[i].toLowerCase();


    if (afinn.isNull(word) == false) {
      float score = afinn.getFloat(word);
      println(word, score);
      totalScore += score;
    }

    //comp.html('comparative: ' + totalScore / words.length);
  }
  println(totalScore);
  switch(totalScore) {
  case 0: 
    e3.play();  
    break;
  case -4:
    e1.play();  
    break;
  case -2:
    e2.play();  
    break; 
  case 2:
    e3.play();  
    break;     
  case 3:
    e4.play();  
    break;
  }
}

class Poem
{
  //fields

  float fontSizeMin = 5;
  float angleDistortion = 0.0;

  float greyscale;
  float x = 0, y = 0;
  float stepSize;
  int counter = 0;
  PFont font;


  //Constructor
  Poem(PFont initialFont, float initialSizeMin, float initialDistortion)
  {
    font = initialFont;
    fontSizeMin = initialSizeMin;
    angleDistortion = initialDistortion;
  }
  //Method


  void drawPoem()
  {
    textAlign(LEFT);
    fill(greyscale);

    float d = dist(x, y, smoothedX, smoothedY); // calculate distance between mouse and origin

    /// setup text style
    greyscale = map(-d, -80, 0, 25, 250);
    textFont(font);              //these functions can only be called under method
    textSize(fontSizeMin+d/4);
    char newLetter = letters.charAt(counter); // new letter is the "counter"th character
    stepSize = textWidth(newLetter);  //get the width of new letter



    if (mousePressed == true) {
      angleDistortion = 5;
    } else {
      angleDistortion = 0;
    }

    /// if the distance is bigger than the width of new letter 
    if (d > stepSize) {
      float angle = atan2(smoothedY-y, smoothedX-x); 

      push();
      translate(x, y);
      rotate(angle + random(angleDistortion));
      text(newLetter, 0, 0);
      pop();

      counter++;
      if (counter > letters.length()-1) counter = 0;

      x = x + cos(angle) * stepSize;
      y = y + sin(angle) * stepSize;
    }
  }
}

//save or clean the canvas

void keyTyped() {
  if (key == 's' || key == 'S') save("MyPoem.png");
}

void keyPressed() {
  if (keyCode == DELETE || keyCode == BACKSPACE) background(255);
}
