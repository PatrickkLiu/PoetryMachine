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



import processing.sound.*;
import websockets.*;
WebsocketServer socket;
PFont Garamond;
String letters = "It goes like this: ";
JSONObject  afinn;
String textinput ;
Poem p1;

SoundFile e1, e2, e3, e4, e5;



void setup() {
  socket = new WebsocketServer(this, 1337, "/p5websocket");
  size(780, 780);
  background(255);
  smooth();

  Garamond=createFont("Garamond.ttf", 32); // load font
  //RobotoMono = createFont("RobotoMono-Regular.ttf", 32);
  //Palatinolino = createFont("Palatino-lino.ttf", 32);

  p1 = new Poem(Garamond, 5, 0); // create new visual poem

  afinn = loadJSONObject("afinn111.json"); // load sentiment analysis json object
  e1 = new SoundFile(this, "e1.mp3");
  e2 = new SoundFile(this, "e2.mp3");
  e3 = new SoundFile(this, "e3.mp3");
  e4 = new SoundFile(this, "e4.mp3");
  e5 = new SoundFile(this, "e5.mp3");
}

void draw() {
  p1.drawPoem();
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

    float d = dist(x, y, mouseX, mouseY); // calculate distance between mouse and origin

    /// setup text style
    greyscale = map(-d, -80, 0, 25, 250);
    textFont(font);              //these functions can only be called under method
    textSize(fontSizeMin+d/2);
    char newLetter = letters.charAt(counter); // new letter is the "counter"th character
    stepSize = textWidth(newLetter);  //get the width of new letter



    if (mousePressed == true) {
      angleDistortion = 5;
    } else {
      angleDistortion = 0;
    }

    /// if the distance is bigger than the width of new letter 
    if (d > stepSize) {
      float angle = atan2(mouseY-y, mouseX-x); 

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
