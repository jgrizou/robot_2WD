#ifndef PositionController_h
#define PositionController_h

#include <SpeedController.h>
#include <PololuEncoder.h>

class PositionController
{
  public:
    PositionController(SpeedController*, PololuEncoder*);
		
    void update();

    void set_maxSpeed(float);
    void set_acceleration(float);
    void set_deceleration(float);

	void moveM0(int);
	void moveM1(int);
	void moves(int, int);

	void reset_encoderM0();
	void reset_encoderM1();
	void reset_encoders();

	void set_status(int);
	int get_status();

  private:
	void update_speed_M0();
	void update_speed_M1();

	SpeedController* spc;
	PololuEncoder* enc;

	int status; //0 stopped, 1 running

	float maxSpeed; //absolute maximum speed
	float acceleration; // increase in speed per second (starting)
	float deceleration; // decrease in speed per second (approach to target)

	float distanceToLimit; // distance to target before limiting max Speed

	int targetM0;
	unsigned long timeM0;
    float currentMaxSpeedM0; // in approach of desired position the max Speed is limited
	float speedM0;

	int targetM1;
	unsigned long timeM1;
    float currentMaxSpeedM1; // in approach of desired position the max Speed is limited
	float speedM1;
};

#endif