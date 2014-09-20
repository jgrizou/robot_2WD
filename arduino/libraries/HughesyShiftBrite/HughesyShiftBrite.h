/*
	HughesyShiftBrite.h - A library to run shiftbrites
	Created by Ashley J. Hughes, 14 Jun 2010.
	ashley.hughes@me.com
	Based on a post found @ http://macetech.com/blog/node/54
*/

#ifndef HughesyShiftBrite_h
#define HughesyShiftBrite_h

#include <Arduino.h>


class HughesyShiftBrite
{
public:
	HughesyShiftBrite(int dataPin, int latchPin, int enablePin, int clockPin);
	void init ();
	void setColor(int r, int g, int b);
	void setPower(int r, int g, int b);
private:
	int _SB_CommandMode;
	int _SB_RedCommand;
	int _SB_GreenCommand;
	int _SB_BlueCommand;
	int _dPin;
	int _lPin;
	int _ePin;
	int _cPin;
	unsigned long _SB_CommandPacket;
	void _SB_SendPacket();
	void _SB_FlashError();
};

#endif