/*
Required connections between Arduino and qik 2s9v1:

      Arduino   qik 2s9v1
-------------------------
           5V - VCC
          GND - GND
      Serial3 - RX/TX
Digital Pin 2 - RESET
*/

#include <PololuQikSerial.h>

String inputString = "";         // a string to hold incoming data
boolean stringComplete = false;  // whether the string is complete

PololuQik2s9v1 qik(4);

void setup()
{
  Serial1.begin(9600);
  inputString.reserve(200);

  qik.init();
}

void loop()
{
  if (stringComplete) {
    Serial1.println(inputString);
    qik.setSpeeds(inputString.toInt(), -inputString.toInt());
    inputString = "";
    stringComplete = false;
  }
  
}



/*
  SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void serialEvent1() {
  while (Serial1.available()) {
    // get the new byte:
    char inChar = (char)Serial1.read(); 
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    if (inChar == '\n') {
      stringComplete = true;
    }else
    {
      // add it to the inputString:
      inputString += inChar;
    }
  }
}
