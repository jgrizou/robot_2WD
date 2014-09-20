
#define M0_OUTA 2
#define M0_OUTA_INTERRUPT 0

#define M0_OUTB 3
#define M0_OUTB_INTERRUPT 1

#define M1_OUTA 20
#define M1_OUTA_INTERRUPT 3

#define M1_OUTB 21
#define M1_OUTB_INTERRUPT 2

volatile int countsM0 = 0;
volatile int errorsM0 = 0;
volatile int countsM1 = 0;
volatile int errorsM1 = 0;

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
  }else if(new_M0_OUTB_state ^ M0_OUTA_state)
  {
    countsM0 -= 1;
  }
  else if(new_M0_OUTA_state != M0_OUTA_state && new_M0_OUTB_state != M0_OUTB_state)
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
  }else if(new_M1_OUTB_state ^ M1_OUTA_state)
  {
    countsM1 -= 1;
  }
  else if(new_M1_OUTA_state != M1_OUTA_state && new_M1_OUTB_state != M1_OUTB_state)
  {
    errorsM1 += 1;
  }
  
  M1_OUTA_state = new_M1_OUTA_state;
  M1_OUTB_state = new_M1_OUTB_state;
}
  
void setup()
{
  Serial1.begin(9600);
  
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

void loop()
{
  Serial1.print(countsM0);
  Serial1.print(":");
  Serial1.print(errorsM0);
  Serial1.print("   ");
  Serial1.print(countsM1);
  Serial1.print(":");
  Serial1.println(errorsM1);
  delay(100);
}



