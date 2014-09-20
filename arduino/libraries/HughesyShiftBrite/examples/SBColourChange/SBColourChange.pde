#include "HughesyShiftBrite.h"

HughesyShiftBrite sb(13,12,11,10);

void setup()
{
  sb.init();
}

void loop()
{
  sb.sendColour(0,0,1023);
  delay(500);
  sb.sendColour(0,1023,0);
  delay(500);
  sb.sendColour(1023,0,0);
  delay(500);
}
