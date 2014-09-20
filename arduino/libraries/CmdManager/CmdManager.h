#ifndef CmdManager_h
#define CmdManager_h

#include <CmdMessenger.h> 
#include <PositionController.h>
#include <SpeedController.h>
#include <PololuEncoder.h>
#include <Gripper.h>
#include <HughesyShiftBrite.h>
#include <TimerOne.h>

#define UNKNOWNCMD 10
#define SETFLOATPRECISION 11
#define SETTIMERMICROSEC 12

#define MOVEXCOUNT 20
#define GETCOUNT 21
#define COUNT 22
#define RESETCOUNT 23
#define RESETEDCOUNT 24
#define SETPOSCONTROLSTATUS 25
#define SETACCELERATION 26
#define SETDECELERATION 27
#define SETMAXSPEED 28

#define SETSPEED 40
#define GETSPEED 41
#define SPEED 42
#define SETPID 43
#define SETPIDLIMIT 44

#define SETSERVOPOSITION 50
#define SETGRIPPERPOSITION 51

#define SETLEDCOLOR 60
#define SETLEDPOWER 61

class CmdManager
{
  public:
	CmdManager(Stream &, PositionController*, SpeedController*, PololuEncoder*, Gripper*, HughesyShiftBrite*, TimerOne*);
		
	void init(void*);

	void update();

  private:

  	CmdMessenger* cmdMessenger;

	PositionController* poc;
	SpeedController* spc;
	PololuEncoder* enc;
	Gripper* grip;
	HughesyShiftBrite* sb;
	TimerOne* tim;

	int floatPrintDecimal;

	void OnUnknownCommand();
	static void Wrapper_OnUnknownCommand();

	void SetFloatPrecision();
	static void Wrapper_SetFloatPrecision();

	void MoveXCount();
	static void Wrapper_MoveXCount();

	void GetCount();
	static void Wrapper_GetCount();

	void ResetCount();
	static void Wrapper_ResetCount();

	void SetPosControlStatus();
	static void Wrapper_SetPosControlStatus();
	
	void SetAcceleration();
	static void Wrapper_SetAcceleration();
	
	void SetDeceleration();
	static void Wrapper_SetDeceleration();
	
	void SetMaxSpeed();
	static void Wrapper_SetMaxSpeed();

	void SetSpeed();
	static void Wrapper_SetSpeed();

	void GetSpeed();
	static void Wrapper_GetSpeed();

	void SetPid();
	static void Wrapper_SetPid();

	void SetPidLimit();
	static void Wrapper_SetPidLimit();

	void SetTimerMicroSec();
	static void Wrapper_SetTimerMicroSec();

	void SetServoPosition();
	static void Wrapper_SetServoPosition();

	void SetGripperPosition();
	static void Wrapper_SetGripperPosition();

	void SetLedColor();
	static void Wrapper_SetLedColor();

	void SetLedPower();
	static void Wrapper_SetLedPower();
};

#endif