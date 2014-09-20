#include <Servo.h>

#include <CmdManager.h>
#include <CmdMessenger.h>
#include <PID_v1.h>
#include <TimerOne.h>

#include <PositionController.h>
#include <SpeedController.h>
#include <PololuQikSerial.h>
#include <PololuEncoder.h>
#include <SimpleDeque.h>
#include <Gripper.h>
#include <HughesyShiftBrite.h>

PololuQik2s9v1 qik(Serial3, 4);
PololuEncoder enc;
SpeedController spc(&qik, &enc);
PositionController poc(&spc, &enc);
Gripper grip(5, 6);
HughesyShiftBrite sb(13,12,11,10);


CmdManager cmdManager = CmdManager(Serial1, &poc, &spc, &enc, &grip, &sb, &Timer1);

void setup()
{
  Serial1.begin(19200);
  Serial3.begin(38400); // serial for communication with the motor controller, baudrate shou

  qik.init();
  enc.init();
  grip.init();
  sb.init();
  cmdManager.init((void*) &cmdManager); //ugly but enable callback inside class
  
  Timer1.initialize(50000); // set a timer of length 50000 microseconds or 0.2 sec or 20Hz
  Timer1.attachInterrupt(timerIsr); // attach the service routine here
}

void loop()
{
  cmdManager.update();
}

/// --------------------------
/// Custom ISR Timer Routine
/// --------------------------
void timerIsr()
{
  poc.update();
  spc.update();
}