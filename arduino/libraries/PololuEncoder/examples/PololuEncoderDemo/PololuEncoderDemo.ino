#include <PololuEncoder.h>

PololuEncoder enc;

void setup()
{
  Serial.begin(115200);
  enc.init();
}

void loop()
{
  Serial.print(enc.get_countsM0());
  Serial.print(":");
  Serial.print(enc.get_errorsM0());
  Serial.print("   ");
  Serial.print(enc.get_countsM1());
  Serial.print(":");
  Serial.println(enc.get_errorsM1());
  delay(10);
}
