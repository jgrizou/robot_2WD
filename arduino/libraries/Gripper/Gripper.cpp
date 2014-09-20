#include "Gripper.h"

Gripper::Gripper(int myServoLeftPin, int myServoRightPin)
{
	servoLeftPin = myServoLeftPin;
	servoRightPin = myServoRightPin;
}

void Gripper::init()
{
	servoLeft.attach(servoLeftPin);
	servoRight.attach(servoRightPin);
}

void Gripper::set_servos_positions(int servoLeftPos, int servoRightPos)
{
	servoLeft.write(servoLeftPos);
	servoRight.write(servoRightPos);
}
void Gripper::set_gripper_position(int gripperPos)
{
	servoLeft.write(gripperPos);
	servoRight.write(180-gripperPos);
}