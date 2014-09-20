#ifndef Gripper_h
#define Gripper_h

#include <Servo.h> 

class Gripper
{
  public:
    Gripper(int servoLeftPin, int servoRightPin);

    int servoLeftPin;
    int servoRightPin;

	Servo servoLeft;
	Servo servoRight;

    void init();

    void set_servos_positions(int servoLeftPos, int servoRightPos);
	void set_gripper_position(int gripperPos);
};

#endif