#include <PololuQikSerial.h>
#include <PololuEncoder.h>

String inputString = "";         // a string to hold incoming data
boolean stringComplete = false;  // whether the string is complete

PololuQik2s9v1 qik(2);
PololuEncoder enc;

int SetpointM0, StartPointM0, CurrentPointM0, DriveM0;
int SetpointM1, StartPointM1, CurrentPointM1, DriveM1;

void setup()
{
  Serial.begin(115200);
  inputString.reserve(200);

  qik.init();
  enc.init();
  
  SetpointM0 = 0;
  StartPointM0 = 0;
  CurrentPointM0 = 0;
  
  SetpointM1 = 0;
  StartPointM1 = 0;
  CurrentPointM1 = 0;
}

void target()
{
  int maxSpeed = 100;
  double slope = 1;
  CurrentPointM0 = enc.get_countsM0();
  DriveM0 = getSpeed(StartPointM0, CurrentPointM0, SetpointM0, slope, maxSpeed);
  
  CurrentPointM1 = enc.get_countsM1();
  DriveM1 = getSpeed(StartPointM1, CurrentPointM1, SetpointM1, slope, maxSpeed);
      
  Serial.print(SetpointM0);
  Serial.print(":");
  Serial.print(CurrentPointM0);
  Serial.print(":");
  Serial.println(DriveM0);
    
  Serial.print(SetpointM1);
  Serial.print(":");
  Serial.print(CurrentPointM1);
  Serial.print(":");
  Serial.println(DriveM1);
  
  qik.setSpeeds(DriveM0, DriveM1);
}

int getSpeed(int start, int current, int set, double slope, int maxSpeed)
{  
  int cSpeed;
  
  int diffEnd = set - current;
  int signEnd = 1;
  if (diffEnd < 0)
  {
    signEnd = -1;
    diffEnd = - diffEnd;
  }
  int diffStart = start - current;
  if (diffStart  < 0)
  {
    diffStart = - diffStart;
  }
  
  if (diffStart < diffEnd)
  {
    cSpeed = (int) diffStart * slope;
  }else{
    cSpeed = (int) diffEnd * slope;
  }
  
  if (cSpeed > maxSpeed) cSpeed = maxSpeed;
  cSpeed = signEnd * cSpeed;
  return cSpeed;
}


void loop()
{
  if (stringComplete) {
    Serial.println(inputString);
    SetpointM0 = (double) inputString.toInt(); 
    StartPointM0 = enc.get_countsM0();

    SetpointM1 = (double) -inputString.toInt();
    StartPointM1 = enc.get_countsM1();
    
    inputString = "";
    stringComplete = false;
  }
  target();
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
