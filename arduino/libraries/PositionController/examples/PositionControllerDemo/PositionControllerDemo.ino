#include <PositionController.h>
#include <SpeedController.h>
#include <PololuQikSerial.h>
#include <PololuEncoder.h>
#include <SimpleDeque.h>
#include <PID_v1.h>

PololuQik2s9v1 qik(4);
PololuEncoder enc;
SpeedController spc(&qik, &enc);
PositionController poc(&spc, &enc);

String inputString = "";         // a string to hold incoming data
boolean stringComplete = false;  // whether the string is complete

int timer1_counter;

void setup()
{
  Serial1.begin(19200);
  inputString.reserve(200);

  qik.init();
  enc.init();
  
  spc.set_PID_param(0., 1., 0.);
  spc.set_PID_limit(50.);
  
  poc.set_maxSpeed(40.0);
  poc.set_deceleration(20.0);
  poc.set_acceleration(100.0);
  
  // initialize timer1 
  noInterrupts(); // disable all interrupts
  TCCR1A = 0;
  TCCR1B = 0;
  // Set timer1_counter to the correct value for our interrupt interval
  timer1_counter = compute_counter(20, 256);
  TCNT1 = timer1_counter;   // preload timer
  TCCR1B |= (1 << CS12);    // 256 prescaler 
  TIMSK1 |= (1 << TOIE1);   // enable timer overflow interrupt
  interrupts();    
}

int compute_counter(int freq, int prescaler)
{
  //65536-(1/Hz)/(prescaler/16000000)
  return 65536-(16000000/(prescaler*freq));
  //62411 for prescale 256 at 20Hz
  //59286 for prescale 256 at 10Hz
}

void loop()
{
  if (stringComplete) {
//    spc.set_speeds((float) inputString.toInt(), (float) -inputString.toInt());
    poc.moves(inputString.toInt(), -inputString.toInt());
    inputString = "";
    stringComplete = false;
  }
  Serial1.print(spc.get_speedM0());
  Serial1.print(" : ");
  Serial1.print(enc.get_countsM0());
  Serial1.print(" || ");
  Serial1.print(spc.get_speedM1());
  Serial1.print(" : ");
  Serial1.println(enc.get_countsM1());
  delay(200);
}

ISR(TIMER1_OVF_vect) // interrupt service routine 
{
  TCNT1 = timer1_counter; // reload timer
  poc.update();
  spc.update();
}

/*
  SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void serialEvent1() {
  while (Serial1.available()) {
    // get the new byte:
    char inChar = (char)Serial1.read(); 
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    if (inChar == '\n') {
      stringComplete = true;
    }else
    {
      // add it to the inputString:
      inputString += inChar;
    }
  }
}