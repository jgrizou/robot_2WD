#include "PositionController.h"

PositionController::PositionController(SpeedController* mySpc, PololuEncoder* myEnc)
{
  spc = mySpc;
  enc = myEnc;

  set_maxSpeed(40.0);
  set_deceleration(20.0);
  set_acceleration(100.0);

  currentMaxSpeedM0 = 0;
  currentMaxSpeedM1 = 0;

  status = 1; // running

  timeM0 = micros();
  timeM1 = micros();
  moves(0, 0);
}

void PositionController::set_status(int newStatus)
{
  if (newStatus == 1)
  {
    moves(0, 0);
  }
  status = newStatus;
}

int PositionController::get_status()
{
  return status;
}
  
void PositionController::update()
{
  if (status != 0)
  {
    update_speed_M0();
    update_speed_M1();
  }
}

void PositionController::set_maxSpeed(float newMaxSpeed)
{
  maxSpeed = newMaxSpeed;
}

void PositionController::set_acceleration(float newAcc)
{
  acceleration = newAcc;
}

void PositionController::set_deceleration(float newDec)
{
  deceleration = newDec;
  distanceToLimit = (maxSpeed/deceleration) * (maxSpeed/deceleration);
}

void PositionController::reset_encoderM0()
{
  int remainingM0 = targetM0 - enc->get_countsM0();
  spc->reset_encoderM0();
  targetM0 = remainingM0;
}

void PositionController::reset_encoderM1()
{
  int remainingM1 = targetM1 - enc->get_countsM1();
  spc->reset_encoderM1();
  targetM1 = remainingM1;
}

void PositionController::reset_encoders()
{
  reset_encoderM0();
  reset_encoderM1();
}

void PositionController::moveM0(int positionDiff)
{
  targetM0 = enc->get_countsM0() + positionDiff;
}

void PositionController::moveM1(int positionDiff)
{
  targetM1 = enc->get_countsM1() + positionDiff;
}

void PositionController::moves(int positionDiffM0, int positionDiffM1)
{
  moveM0(positionDiffM0);
  moveM1(positionDiffM1);
}

void PositionController::update_speed_M0()
{
  unsigned long t = micros();
  unsigned long dtM0 = t - timeM0;
  timeM0 = t;
  //compute distance to target
  int distM0 = targetM0 - enc->get_countsM0();
  //update currentMaxSpeedM0
  if (abs(distM0) > distanceToLimit)
  {
    currentMaxSpeedM0 = maxSpeed;
  } else
  {
    currentMaxSpeedM0 = (maxSpeed / distanceToLimit) * abs(distM0);
  }

  float newSpeedM0;
  if (distM0 > 0)
  {
    newSpeedM0 = speedM0 + acceleration * dtM0 / 1000000.0;
  }
  else
  {
    newSpeedM0 = speedM0 - acceleration * dtM0 / 1000000.0;
  }

  if (abs(newSpeedM0) > currentMaxSpeedM0)
  {
      if (newSpeedM0 > 0)
      {
        newSpeedM0 = currentMaxSpeedM0;
      }
      else
      {
        newSpeedM0 = -currentMaxSpeedM0;
      }
  }

  if (newSpeedM0 != speedM0)
  {
    speedM0 = newSpeedM0;
    spc->set_speedM0(speedM0);
  }

  // Serial1.print(distM0);
  // Serial1.print(" : ");
  // Serial1.print(distanceToLimit);
  // Serial1.print(" : ");
  // Serial1.print(currentMaxSpeedM0);
  // Serial1.print(" : ");
  // Serial1.println(speedM0);
}

void PositionController::update_speed_M1()
{
  unsigned long t = micros();
  unsigned long dtM1 = t - timeM1;
  timeM1 = t;
  //compute distance to target
  int distM1 = targetM1 - enc->get_countsM1();
  //update currentMaxSpeedM1
  if (abs(distM1) > distanceToLimit)
  {
    currentMaxSpeedM1 = maxSpeed;
  } else
  {
    currentMaxSpeedM1 = (maxSpeed / distanceToLimit) * abs(distM1);
  }

  float newSpeedM1;
  if (distM1 > 0)
  {
    newSpeedM1 = speedM1 + acceleration * dtM1 / 1000000.0;
  }
  else
  {
    newSpeedM1 = speedM1 - acceleration * dtM1 / 1000000.0;
  }

  if (abs(newSpeedM1) > currentMaxSpeedM1)
  {
      if (newSpeedM1 > 0)
      {
        newSpeedM1 = currentMaxSpeedM1;
      }
      else
      {
        newSpeedM1 = -currentMaxSpeedM1;
      }
  }

  // Serial1.print(distM1);
  // Serial1.print(" : ");
  // Serial1.print(speedM1);
  // Serial1.print(" : ");
  // Serial1.println(newSpeedM1);

  if (newSpeedM1 != speedM1)
  {
    speedM1 = newSpeedM1;
    spc->set_speedM1(speedM1);
  }

}

