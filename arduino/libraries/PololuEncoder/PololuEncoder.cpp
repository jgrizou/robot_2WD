#include "PololuEncoder.h"

volatile int countsM0;
volatile int errorsM0;
volatile int countsM1;
volatile int errorsM1;

volatile boolean M0_OUTA_state;
volatile boolean M0_OUTB_state;
volatile boolean M1_OUTA_state;
volatile boolean M1_OUTB_state;

void update_counts_M0()
{
	boolean new_M0_OUTA_state = digitalRead(M0_OUTA);
	boolean new_M0_OUTB_state = digitalRead(M0_OUTB);
	
	if(new_M0_OUTA_state ^ M0_OUTB_state)
	{
		countsM0 += 1;
	}
	
	if(new_M0_OUTB_state ^ M0_OUTA_state)
	{
		countsM0 -= 1;
	}
	
	if (new_M0_OUTA_state != M0_OUTA_state && new_M0_OUTB_state != M0_OUTB_state)
	{
		errorsM0 += 1;
	}
	
	M0_OUTA_state = new_M0_OUTA_state;
	M0_OUTB_state = new_M0_OUTB_state;
}

void update_counts_M1()
{
	boolean new_M1_OUTA_state = digitalRead(M1_OUTA);
	boolean new_M1_OUTB_state = digitalRead(M1_OUTB);
	
	if(new_M1_OUTA_state ^ M1_OUTB_state)
	{
		countsM1 += 1;
	}
	
	if(new_M1_OUTB_state ^ M1_OUTA_state)
	{
		countsM1 -= 1;
	}
	
	if(new_M1_OUTA_state != M1_OUTA_state && new_M1_OUTB_state != M1_OUTB_state)
	{
		errorsM1 += 1;
	}
	
	M1_OUTA_state = new_M1_OUTA_state;
	M1_OUTB_state = new_M1_OUTB_state;
}


PololuEncoder::PololuEncoder()
{
	countsM0 = 0;
	errorsM0 = 0;

	countsM1 = 0;
	errorsM1 = 0;
}

void PololuEncoder::init()
{
	pinMode(M0_OUTA, INPUT);
	pinMode(M0_OUTB, INPUT);
	M0_OUTA_state = digitalRead(M0_OUTA);
	M0_OUTB_state = digitalRead(M0_OUTB);
	attachInterrupt(M0_OUTA_INTERRUPT, update_counts_M0, CHANGE);
	attachInterrupt(M0_OUTB_INTERRUPT, update_counts_M0, CHANGE);
	
	pinMode(M1_OUTA, INPUT);
	pinMode(M1_OUTB, INPUT);
	M1_OUTA_state = digitalRead(M1_OUTA);
	M1_OUTB_state = digitalRead(M1_OUTB);
	attachInterrupt(M1_OUTA_INTERRUPT, update_counts_M1, CHANGE);
	attachInterrupt(M1_OUTB_INTERRUPT, update_counts_M1, CHANGE);
}

int PololuEncoder::get_countsM0()
{
	return countsM0;
}

int PololuEncoder::get_countsM1()
{
	return countsM1;
}

int PololuEncoder::reset_countsM0()
{
	countsM0 = 0;
}

int PololuEncoder::reset_countsM1()
{
	countsM1 = 0;
}

int PololuEncoder::get_errorsM0()
{
	return errorsM0;
}

int PololuEncoder::get_errorsM1()
{
	return errorsM1;
}
