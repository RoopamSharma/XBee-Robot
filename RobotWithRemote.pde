/* -*- Mode:C++ -*- */
#include <AFMotor.h>
#include <NewSoftSerial.h>

AF_DCMotor left_motor(2, MOTOR12_64KHZ);
AF_DCMotor right_motor(1, MOTOR12_64KHZ);
const int pingPin = 14;

// The Xbee Tx/Rx pins using "analog" pins 1 & 2
const int XBEE_TX=15;
const int XBEE_RX=16;

NewSoftSerial mySerial(XBEE_TX, XBEE_RX);

void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("Robot Remote");

  // set the data rate for the NewSoftSerial port
  mySerial.begin(9600);
  mySerial.println("By your command");
}

long ping() {
  pinMode(pingPin, OUTPUT);
  digitalWrite(pingPin, LOW);
  delayMicroseconds(2);
  digitalWrite(pingPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(pingPin, LOW);

  pinMode(pingPin, INPUT);
  return pulseIn(pingPin, HIGH);
}

long inchesInFront() {
  long duration = ping();
  return microsecondsToInches(duration);
}

void loop() {
  char cmd = 0;

  if (mySerial.available()) {
      cmd = (char)mySerial.read();
  } else if (Serial.available()) {
      cmd = (char)Serial.read();
  }

  if (cmd != 0) {
      Serial.println(cmd);
      switch (cmd) {
      case 'w':
        left_motor.run(FORWARD);
        right_motor.run(FORWARD);
        left_motor.setSpeed(150);
        right_motor.setSpeed(150);
        break;
      case 's':
        left_motor.run(RELEASE);
        right_motor.run(RELEASE);
        left_motor.setSpeed(0);
        right_motor.setSpeed(0);
        break;
      case 'a':
        left_motor.run(BACKWARD);
        right_motor.run(FORWARD);
        left_motor.setSpeed(150);
        right_motor.setSpeed(150);
        break;
      case 'd':
        left_motor.run(FORWARD);
        right_motor.run(BACKWARD);
        left_motor.setSpeed(150);
        right_motor.setSpeed(150);
        break;
      case 'x':
        left_motor.run(BACKWARD);
        right_motor.run(BACKWARD);
        left_motor.setSpeed(150);
        right_motor.setSpeed(150);
        break;

      }
  }

  /*
  // Ping))) code not currently used
  long inches = inchesInFront();

  if (inches > 6) {
    left_motor.run(FORWARD);
    right_motor.run(FORWARD);

    left_motor.setSpeed(150);
    right_motor.setSpeed(150);
    delay(50);
  } else {
    right_motor.run(BACKWARD);
    right_motor.setSpeed(150);

    delay(400);
  }
  */
}

long microsecondsToInches(long microseconds) {
  // According to Parallax's datasheet for the PING))), there are
  // 73.746 microseconds per inch (i.e. sound travels at 1130 feet per
  // second).  This gives the distance travelled by the ping, outbound
  // and return, so we divide by 2 to get the distance of the obstacle.
  // See: http://www.parallax.com/dl/docs/prod/acc/28015-PING-v1.3.pdf
  return microseconds / 74 / 2;
}

long microsecondsToCentimeters(long microseconds) {
  // The speed of sound is 340 m/s or 29 microseconds per centimeter.
  // The ping travels out and back, so to find the distance of the
  // object we take half of the distance travelled.
  return microseconds / 29 / 2;
}

