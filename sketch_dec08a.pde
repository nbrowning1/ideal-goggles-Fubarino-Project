/*
   Seven-segment -> port map
   * top-mid = 8
   * mid-mid = 5
   * btm-mid = 2
   * top-left = 6
   * top-right = 7
   * btm-left = 3
   * btm-right = 4
   * dot = 9
 */

int nums[16][8] = {  
// pin 2  3  4  5  6  7  8, 9   
      {1, 1, 1, 0, 1, 1, 1, 0},  // 0
      {0, 0, 1, 0, 0, 1, 0, 0},  // 1
      {1, 1, 0, 1, 0, 1, 1, 0},  // 2
      {1, 0, 1, 1, 0, 1, 1, 0},  // 3
      {0, 0, 1, 1, 1, 1, 0, 0},  // 4
      {1, 0, 1, 1, 1, 0, 1, 0},  // 5
      {1, 1, 1, 1, 1, 0, 1, 0},  // 6
      {0, 0, 1, 0, 0, 1, 1, 0},  // 7
      {1, 1, 1, 1, 1, 1, 1, 0},  // 8
      {1, 0, 1, 1, 1, 1, 1, 0},  // 9
      {0, 1, 1, 1, 1, 1, 1, 0},  // A
      {1, 1, 1, 1, 1, 0, 0, 0},  // b
      {1, 1, 0, 0, 1, 0, 1, 0},  // C
      {1, 1, 1, 1, 0, 1, 0, 0},  // d
      {0, 0, 0, 0, 0, 0, 0, 1},  // .
      {0, 0, 0, 0, 0, 0, 0, 0}   // ' '
};

int potPin = 10;
int switch1Pin = 19;
int switch2Pin = 0;
int inputPin = 25;

int POTENTIOMETER_RANGE = 1024;
int BRIGHTNESS_LEVELS = 10;
int BRIGHTNESS_DIVISOR = POTENTIOMETER_RANGE / BRIGHTNESS_LEVELS;

int RECEIVE_DELAY = 100;

int readNumber = 0;

void setup() {
  // setup seven-segment pins for output
  for (int i = 2; i <= 9; i++) {
    pinMode(i, OUTPUT);
  }
  
  // initialise serial port for interacting with other board at 9600 baud
  Serial1.begin(9600);
  
  // setup on-board pin for output
  pinMode(1, OUTPUT);
}

void loop() {

  readInputIfAvailable();
  showDimmingNumber();

//  if (digitalRead(switch1Pin)) {
////    Serial.end();
//    Serial.begin(9600);
//    Serial.println(5);
//  } else if (digitalRead(switch2Pin)) {
////    Serial.end();
////    Serial.begin(19200);
//    Serial.println(10);
//  }
//  Serial.println();

  digitalWrite(1, LOW);
}

/**
 * check for input from another board and store it if available
 */
void readInputIfAvailable() {
  if (Serial1.available()) {
    readNumber = Serial1.read();
    // switch on on-board pin to show data received
    digitalWrite(1, HIGH);
  } 
}

/**
 * show a number on the seven-segment display that is dimmed using PWM
 *  according to the value of the potentiometer
 */
void showDimmingNumber() {
  // find out brightness level from potentiometer input
  int brightness = (analogRead(potPin)+1) / BRIGHTNESS_DIVISOR;
  
  // TODO: is this totally necessary?
  // work out number of loops to build delay until next number can be received
  int noOfLoops = RECEIVE_DELAY / (BRIGHTNESS_LEVELS + brightness);
  
  // use PWM to dim seven-segment until enough delay has passed
  for (int i = 0; i < noOfLoops; i++) {
    delay(BRIGHTNESS_LEVELS - brightness);
    showNumber(nums[readNumber]);
    delay(brightness);
    // show ' ' key output - essentially a blank seven-segment
    showNumber(nums[15]);
  }
}

/**
 * show a number on the seven-segment display, given the mappings for each
 *  segment of the display
 */
void showNumber(int mappings[]) {
   for (int i = 0; i <= 7; i++) {
     int pin = i+2;
     if (mappings[i] == 0) {
       digitalWrite(pin, LOW); 
     } else {
       digitalWrite(pin, HIGH);
     }
  }
}
