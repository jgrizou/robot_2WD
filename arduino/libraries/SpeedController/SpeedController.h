#ifndef SpeedController_h
#define SpeedController_h

#include <PololuQikSerial.h>
#include <PololuEncoder.h>
#include <SimpleDeque.h>
#include <PID_v1.h>

class SpeedController
{
  public:
    SpeedController(PololuQik2s9v1*, PololuEncoder*);
		
    void update();

    void set_PID_param(double, double, double);
	void set_PID_limit(double);

	void set_speedM0(float);
	void set_speedM1(float);
	void set_speeds(float, float);
	
	float get_speedM0();
	float get_speedM1();

	void reset_encoderM0();
	void reset_encoderM1();
	void reset_encoders();

  private:

	void update_speed_M0();
	void update_speed_M1();	
	void update_drive_M0();
	void update_drive_M1();
    int compute_init_drive(float);

	PololuQik2s9v1* qik;
	PololuEncoder* enc;

	double KP;
	double KI;
	double KD;

	double PIDSetpointM0, PIDInputM0, PIDOutputM0;
	int DriveM0;
	PID* PIDM0;

	double PIDSetpointM1, PIDInputM1, PIDOutputM1;
	int DriveM1;
	PID* PIDM1;

	unsigned long refTimeM0;
	int refCountM0;
	SimpleDeque<float,5> M0Deque;

	unsigned long refTimeM1;
	int refCountM1;
	SimpleDeque<float,5> M1Deque;
};

#endif