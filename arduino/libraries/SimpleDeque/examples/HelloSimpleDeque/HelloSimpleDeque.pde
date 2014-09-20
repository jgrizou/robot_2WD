#include <SimpleDeque.h>

void setup() {
  Serial1.begin(9600);
  
  SimpleDeque<float,10> sDeque; //store 10 ints
  
  float initValue = 12;
  sDeque.fill(initValue);
  Serial1.println(sDeque.raw[0]);
  Serial1.println(sDeque.sum());
  Serial1.println(sDeque.mean());

  float pushValue = 6;
  sDeque.push(pushValue);
  sDeque.push(pushValue);
  sDeque.push(pushValue);
  sDeque.push(pushValue);
  sDeque.push(pushValue);

  Serial1.println(sDeque.raw[0]);
  Serial1.println(sDeque.sum());
  Serial1.println(sDeque.mean());

}

void loop() {
  //nothing
}


