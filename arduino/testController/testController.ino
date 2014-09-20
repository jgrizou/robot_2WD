#include <PololuQikSerial.h>
#include <PololuEncoder.h>

PololuQik2s9v1 qik(4);
PololuEncoder enc;

String inputString = "";         // a string to hold incoming data
boolean stringComplete = false;  // whether the string is complete


//
boolean hasRefM0;
unsigned long refM0;
int refCountM0;
int shiftCountM0;

#include <SimpleDeque.h>
SimpleDeque<float,10> M0Deque; //store 10 ints

void setup()
{
  Serial1.begin(9600);
  inputString.reserve(200);

  qik.init();
  enc.init();
  
  hasRefM0 = false;
  refCountM0 = 0;
}

void setSpeed(float M0, float M1)
{   
  float a = 0.5; //should be 0.53
  float b = 0; // should be 6.5
  int driveM0 = (int) abs(M0)*a+b;
  if (M0 < 0)
  {
    driveM0 = - driveM0;
  }
  int driveM1 = (int) abs(M1)*a+b;
    if (M1 < 0)
  {
    driveM1 = - driveM1;
  }
  Serial1.print(driveM0);
  Serial1.print(" : ");
  Serial1.println(driveM1);
  qik.setSpeeds(driveM0, driveM1);
  hasRefM0 = false;
  refCountM0 = enc.get_countsM0();
  shiftCountM0 = 0;
  M0Deque.fill(M0);
}

void updateController()
{
  int countM0 = enc.get_countsM0() - refCountM0;
  if (!hasRefM0) 
  {
    if (countM0 != 0)
    {
      refM0 = micros();
      hasRefM0 = true;
      shiftCountM0 = countM0;
    }
  } 
  else
  {
    float dt = micros() - refM0;
    M0Deque.push(abs(countM0-shiftCountM0) * 1000000 / dt);

    shiftCountM0 = countM0;
    refM0 = micros();
  }
}

void loop()
{
  if (stringComplete) {
    setSpeed((float) inputString.toInt(), (float) -inputString.toInt());
    inputString = "";
    stringComplete = false;
  }
  updateController();
  Serial1.println(M0Deque.mean());
  delay(100);
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
