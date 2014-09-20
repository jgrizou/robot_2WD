#include "SpeedController.h"

SpeedController::SpeedController(PololuQik2s9v1* myQik, PololuEncoder* myEnc)
{
	qik = myQik;
	enc = myEnc;

	PIDM0 = new PID(&PIDInputM0, &PIDOutputM0, &PIDSetpointM0, 0.0, 1.0, 0.0, DIRECT);
	PIDM0->SetMode(AUTOMATIC);
	PIDM0->SetOutputLimits(-50.0, 50.0);

	PIDM1 = new PID(&PIDInputM1, &PIDOutputM1, &PIDSetpointM1, 0.0, 1.0, 0.0, DIRECT);
	PIDM1->SetMode(AUTOMATIC);
	PIDM1->SetOutputLimits(-50.0, 50.0);

  refTimeM0 = micros();
  refCountM0 = enc->get_countsM0();
  M0Deque.fill(0.0f);

  refTimeM1 = micros();
  refCountM1 = enc->get_countsM1();
  M1Deque.fill(0.0f);

}

void SpeedController::set_PID_param(double newKP, double newKI, double newKD)
{
	PIDM0->SetTunings(newKP, newKI, newKD);
  PIDM1->SetTunings(newKP, newKI, newKD);
}

void SpeedController::set_PID_limit(double limit)
{
  PIDM0->SetOutputLimits(-limit, limit);
  PIDM1->SetOutputLimits(-limit, limit);
}

void SpeedController::reset_encoderM0()
{
  int diffCountM0 = enc->get_countsM0() - refCountM0;
  enc->reset_countsM0();
  refCountM0 =  -diffCountM0;
}

void SpeedController::reset_encoderM1()
{
  int diffCountM1 = enc->get_countsM1() - refCountM1;
  enc->reset_countsM1();
  refCountM1 =  -diffCountM1;
}

void SpeedController::reset_encoders()
{
  reset_encoderM0();
  reset_encoderM1();
}

void SpeedController::update_speed_M0()
{	
  float dt = micros() - refTimeM0;
  int countM0 = enc->get_countsM0();
  M0Deque.push((countM0 - refCountM0) * (1000000.0 / dt));
  refCountM0 = countM0;
  refTimeM0 = refTimeM0 + dt;
}

void SpeedController::update_speed_M1()
{  
  float dt = micros() - refTimeM1;
  int countM1 = enc->get_countsM1();
  M1Deque.push((countM1 - refCountM1) * (1000000.0 / dt));
  refCountM1 = countM1;
  refTimeM1 = refTimeM1 + dt;
}

void SpeedController::update_drive_M0()
{
	PIDInputM0 = get_speedM0();
  PIDM0->Compute();
  qik->setM0Speed(DriveM0 + (int) PIDOutputM0);
}

void SpeedController::update_drive_M1()
{
	PIDInputM1 = get_speedM1();
  PIDM1->Compute();
  qik->setM1Speed(DriveM1 + (int) PIDOutputM1);
}

void SpeedController::update()
{  
	update_speed_M0();
	update_drive_M0();

	update_speed_M1();
	update_drive_M1();
}

int SpeedController::compute_init_drive(float speed)
{
  if (speed == 0.0f)
  {
  	return 0;
  }
  float a = 0.53; //should be 0.53
  float b = 6.5; // should be 6.5
  int drive = (int) abs(speed)*a + b;
  if (speed < 0)
  {
    drive = - drive;
  }
  return drive;
}

void SpeedController::set_speedM0(float speed)
{
  PIDSetpointM0 = speed;
  DriveM0 = compute_init_drive(speed);
  M0Deque.fill(speed);
}

void SpeedController::set_speedM1(float speed)
{
  PIDSetpointM1 = speed;
  DriveM1 = compute_init_drive(speed);
  M1Deque.fill(speed);
}

void SpeedController::set_speeds(float speedM0, float speedM1)
{
	set_speedM0(speedM0);
	set_speedM1(speedM1);
}

float SpeedController::get_speedM0()
{
	return M0Deque.mean();
}

float SpeedController::get_speedM1()
{
	return M1Deque.mean();
}

