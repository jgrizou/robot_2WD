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
#include <PololuEncoder.h>
#include <PID_v1.h>

String inputString = "";         // a string to hold incoming data
boolean stringComplete = false;  // whether the string is complete

PololuQik2s9v1 qik(2);
PololuEncoder enc;

double KP = 1;
double KI = 0;
double KD = 0;

double SetpointM0, InputM0, OutputM0;
int DriveM0;
PID PIDM0(&InputM0, &OutputM0, &SetpointM0, KP, KI, KD, DIRECT);

double SetpointM1, InputM1, OutputM1;
int DriveM1;
PID PIDM1(&InputM1, &OutputM1, &SetpointM1, KP, KI, KD, DIRECT);

void setup()
{
  Serial.begin(115200);
  inputString.reserve(200);

  qik.init();
  enc.init();
  
  //turn the PID on
  PIDM0.SetMode(AUTOMATIC);
  PIDM0.SetOutputLimits(-127.0, 127.0);
  
  PIDM1.SetMode(AUTOMATIC);
  PIDM1.SetOutputLimits(-127.0, 127.0);
}

void loop()
{
  if (stringComplete) {
    Serial.println(inputString);
    SetpointM0 = (double) inputString.toInt(); 
    SetpointM1 = (double) -inputString.toInt(); 
    inputString = "";
    stringComplete = false;
  }
  
  target();
  
}

int format_drive(int drive)
{
 int threshold = 15;
 if (drive > 3)
 {
   drive += threshold; 
 }
 if (drive < 3)
 {
   drive -= threshold; 
 }
 return drive;
}

void target()
{
    InputM0 = (double) enc.get_countsM0();
    InputM1 = (double) enc.get_countsM1();

    PIDM0.Compute();
    PIDM1.Compute();

    DriveM0 = (int) OutputM0;
    DriveM1 = (int) OutputM1;
    
    DriveM0 = format_drive(DriveM0);
    DriveM1 = format_drive(DriveM1);
    
    Serial.print(InputM0);
    Serial.print(":");
    Serial.print(OutputM0);
    Serial.print(":");
    Serial.println(DriveM0);
    
    Serial.print(InputM1);
    Serial.print(":");
    Serial.print(OutputM1);
    Serial.print(":");
    Serial.println(DriveM1);
    
    qik.setSpeeds(DriveM0, DriveM1);
}


/*
  SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read(); 
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
