#include "CmdManager.h"
void* pt2Object;

CmdManager::CmdManager(Stream & comms, PositionController* myPoc, SpeedController* mySpc, PololuEncoder* myEnc, Gripper* myGrip, HughesyShiftBrite* mySb, TimerOne* myTim)
{

  cmdMessenger = new CmdMessenger(comms);

  poc = myPoc;
  spc = mySpc;
  enc = myEnc;
  grip = myGrip;
  sb = mySb;
  tim = myTim;

  floatPrintDecimal = 2;
}

void CmdManager::init(void* mySelf)
{
  pt2Object = mySelf;

  // Adds newline to every command
  cmdMessenger->printLfCr();   
  // Attach my Wrapper
  cmdMessenger->attach(Wrapper_OnUnknownCommand);
  cmdMessenger->attach(SETFLOATPRECISION, Wrapper_SetFloatPrecision);
  cmdMessenger->attach(SETTIMERMICROSEC, Wrapper_SetTimerMicroSec);

  cmdMessenger->attach(MOVEXCOUNT, Wrapper_MoveXCount);
  cmdMessenger->attach(GETCOUNT, Wrapper_GetCount);
  cmdMessenger->attach(RESETCOUNT, Wrapper_ResetCount);
  cmdMessenger->attach(SETPOSCONTROLSTATUS, Wrapper_SetPosControlStatus);
  cmdMessenger->attach(SETACCELERATION, Wrapper_SetAcceleration);
  cmdMessenger->attach(SETDECELERATION, Wrapper_SetDeceleration);
  cmdMessenger->attach(SETMAXSPEED, Wrapper_SetMaxSpeed);

  cmdMessenger->attach(SETSPEED, Wrapper_SetSpeed);
  cmdMessenger->attach(GETSPEED, Wrapper_GetSpeed);
  cmdMessenger->attach(SETPID, Wrapper_SetPid);
  cmdMessenger->attach(SETPIDLIMIT, Wrapper_SetPidLimit);

  cmdMessenger->attach(SETSERVOPOSITION, Wrapper_SetServoPosition);
  cmdMessenger->attach(SETGRIPPERPOSITION, Wrapper_SetGripperPosition);

  cmdMessenger->attach(SETLEDCOLOR, Wrapper_SetLedColor);
  cmdMessenger->attach(SETLEDPOWER, Wrapper_SetLedPower);
}

void CmdManager::update()
{
  cmdMessenger->feedinSerialData();
}

//UNKNOWNCMD
void CmdManager::OnUnknownCommand()
{
  cmdMessenger->sendCmdStart(UNKNOWNCMD);
  cmdMessenger->sendCmdEnd();
}

void CmdManager::Wrapper_OnUnknownCommand()
{
  // explicitly cast to a pointer to Classname
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->OnUnknownCommand();
}

//SETFLOATPRECISION
void CmdManager::SetFloatPrecision()
{
  floatPrintDecimal = cmdMessenger->readIntArg();
}

void CmdManager::Wrapper_SetFloatPrecision()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->SetFloatPrecision();
}

//MOVEXCOUNT
void CmdManager::MoveXCount()
{
  int M0diff = cmdMessenger->readIntArg();
  int M1diff = cmdMessenger->readIntArg();
  poc->moves(M0diff, M1diff);
}

void CmdManager::Wrapper_MoveXCount()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->MoveXCount();
}

//GETCOUNT
void CmdManager::GetCount()
{
  cmdMessenger->sendCmdStart(COUNT);
  cmdMessenger->sendCmdArg(enc->get_countsM0());
  cmdMessenger->sendCmdArg(enc->get_countsM1());
  cmdMessenger->sendCmdEnd();
}

void CmdManager::Wrapper_GetCount()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->GetCount();
}

//RESETCOUNT
void CmdManager::ResetCount()
{
  cmdMessenger->sendCmdStart(RESETEDCOUNT);
  cmdMessenger->sendCmdArg(enc->get_countsM0());
  cmdMessenger->sendCmdArg(enc->get_countsM1());
  poc->reset_encoders();
  cmdMessenger->sendCmdEnd();
}

void CmdManager::Wrapper_ResetCount()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->ResetCount();
}

//SETPOSCONTROLSTATUS
void CmdManager::SetPosControlStatus()
{
  poc->set_status(cmdMessenger->readIntArg());
}

void CmdManager::Wrapper_SetPosControlStatus()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->SetPosControlStatus();
}

//SETACCELERATION
void CmdManager::SetAcceleration()
{
  poc->set_acceleration(cmdMessenger->readFloatArg());
}

void CmdManager::Wrapper_SetAcceleration()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->SetAcceleration();
}

//SETDECELERATION
void CmdManager::SetDeceleration()
{
  poc->set_deceleration(cmdMessenger->readFloatArg());
}

void CmdManager::Wrapper_SetDeceleration()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->SetDeceleration();
}

//SETMAXSPEED
void CmdManager::SetMaxSpeed()
{
  poc->set_maxSpeed(cmdMessenger->readFloatArg());
}

void CmdManager::Wrapper_SetMaxSpeed()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->SetMaxSpeed();
}

//SETSPEED
void CmdManager::SetSpeed()
{
  spc->set_speeds(cmdMessenger->readFloatArg(), cmdMessenger->readFloatArg());
}

void CmdManager::Wrapper_SetSpeed()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->SetSpeed();
}

//GETSPEED
void CmdManager::GetSpeed()
{
  cmdMessenger->sendCmdStart(SPEED);
  cmdMessenger->sendCmdArg(spc->get_speedM0(), floatPrintDecimal);
  cmdMessenger->sendCmdArg(spc->get_speedM1(), floatPrintDecimal);
  cmdMessenger->sendCmdEnd();
}

void CmdManager::Wrapper_GetSpeed()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->GetSpeed();
}

//SETPID
void CmdManager::SetPid()
{
  float KP = cmdMessenger->readFloatArg();
  float KI = cmdMessenger->readFloatArg();
  float KD = cmdMessenger->readFloatArg();
  spc->set_PID_param(KP, KI, KD);
}

void CmdManager::Wrapper_SetPid()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->SetPid();
}

//SETPIDLIMIT
void CmdManager::SetPidLimit()
{
  spc->set_PID_limit(cmdMessenger->readFloatArg());
}

void CmdManager::Wrapper_SetPidLimit()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->SetPidLimit();
}

//SETTIMERMICROSEC
void CmdManager::SetTimerMicroSec()
{
  tim->setPeriod(cmdMessenger->readLongArg());
}

void CmdManager::Wrapper_SetTimerMicroSec()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->SetTimerMicroSec();
}

//SETSERVOPOSITION
void CmdManager::SetServoPosition()
{
  int servoLeftPos = cmdMessenger->readIntArg();
  int servoRightPos = cmdMessenger->readIntArg();
  grip->set_servos_positions(servoLeftPos, servoRightPos);
}

void CmdManager::Wrapper_SetServoPosition()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->SetServoPosition();
}


//SETGRIPPERPOSITION
void CmdManager::SetGripperPosition()
{
  grip->set_gripper_position(cmdMessenger->readIntArg());
}

void CmdManager::Wrapper_SetGripperPosition()
{
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->SetGripperPosition();
}

//SETLEDCOLOR
void CmdManager::SetLedColor()
{
  int redValue = cmdMessenger->readIntArg();
  int greenValue = cmdMessenger->readIntArg();
  int blueValue = cmdMessenger->readIntArg();
  sb->setColor(redValue, greenValue, blueValue);
}

void CmdManager::Wrapper_SetLedColor()
{  
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->SetLedColor();
}

//SETLEDPOWER
void CmdManager::SetLedPower()
{
  int redValue = cmdMessenger->readIntArg();
  int greenValue = cmdMessenger->readIntArg();
  int blueValue = cmdMessenger->readIntArg();
  sb->setPower(redValue, greenValue, blueValue);
}

void CmdManager::Wrapper_SetLedPower()
{  
  CmdManager* mySelf = (CmdManager*) pt2Object;
  mySelf->SetLedPower();
}



