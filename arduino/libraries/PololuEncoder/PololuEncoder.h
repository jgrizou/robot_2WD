#ifndef PololuEncoder_h
#define PololuEncoder_h

#include <Arduino.h>

#define M0_OUTA 2
#define M0_OUTA_INTERRUPT 0

#define M0_OUTB 3
#define M0_OUTB_INTERRUPT 1

#define M1_OUTA 20
#define M1_OUTA_INTERRUPT 3

#define M1_OUTB 21
#define M1_OUTB_INTERRUPT 2

void update_counts_M0();
void update_counts_M1();

class PololuEncoder
{
  public:
    PololuEncoder();
	
    void init();
	
	int get_countsM0();
	int get_countsM1();
	
	int reset_countsM0();
	int reset_countsM1();
	
	int get_errorsM0();
	int get_errorsM1();
};

#endif
