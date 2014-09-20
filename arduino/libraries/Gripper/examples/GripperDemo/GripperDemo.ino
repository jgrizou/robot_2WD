#include <Servo.h> 
#include <Gripper.h>


Gripper g(5, 6);

void setup()
{
	g.init();
	
}

void loop()
{
  g.set_gripper_position(180);
  delay(1000);
  g.set_gripper_position(50);
  delay(1000);
}