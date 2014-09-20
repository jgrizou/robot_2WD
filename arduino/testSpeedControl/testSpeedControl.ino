#include <PololuQikSerial.h>
#include <PololuEncoder.h>

PololuQik2s9v1 qik(4);
PololuEncoder enc;

String inputString = "";         // a string to hold incoming data
boolean stringComplete = false;  // whether the string is complete

void setup()
{
  Serial1.begin(9600);
  inputString.reserve(200);

  qik.init();
  enc.init();
}

void loop()
{
  if (stringComplete) {
    Serial1.println(inputString);
    Serial1.println(micros());
    Serial1.print(enc.get_countsM0());
    Serial1.print(":");
    Serial1.print(enc.get_errorsM0());
    Serial1.print("   ");
    Serial1.print(enc.get_countsM1());
    Serial1.print(":");
    Serial1.println(enc.get_errorsM1());
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
