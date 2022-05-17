// Adapted from the MIDIUSB library example MIDIUSB_buzzer
#include <MIDIUSB.h>

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(1, OUTPUT);
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
//  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
  pinMode(8, OUTPUT);
//  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
  pinMode(12, OUTPUT);
  pinMode(13, OUTPUT);
  pinMode(14, OUTPUT);
  pinMode(15, OUTPUT);
  Serial.begin(115200);
}

void loop() {
  midiEventPacket_t rx = MidiUSB.read();
  switch (rx.header) {
    case 0:
      break; //No pending events
      
    case 0x9:
      noteOn(
        rx.byte1 & 0xF,  //channel
        rx.byte2,        //pitch
        rx.byte3         //velocity
      );
      break;
      
    case 0x8:
      noteOff(
        rx.byte1 & 0xF,  //channel
        rx.byte2,        //pitch
        rx.byte3         //velocity
      );
      break;
      
    default:
      Serial.print("Unhandled MIDI message: ");
//      Serial.print(rx.header, HEX);
//      Serial.print("-");
//      Serial.print(rx.byte1, HEX);
//      Serial.print("-");
//      Serial.print(rx.byte2, HEX);
//      Serial.print("-");
//      Serial.println(rx.byte3, HEX);
  }
}

void noteOn(byte channel, byte pitch, byte velocity) {

//  syntax for octave:          ...&& pitch_octave(pitch) == 3...
    if (pitch_name(pitch) == "C") {
    digitalWrite(12, HIGH);
    delay(18);
    digitalWrite(12, LOW);
  }

    if (pitch_name(pitch) == "C#") {
    digitalWrite(11, HIGH);
    delay(18);
    digitalWrite(11, LOW);
  }

    if (pitch_name(pitch) == "D") {
    digitalWrite(10, HIGH);
    delay(18);
    digitalWrite(10, LOW);
  }

    if (pitch_name(pitch) == "D#") {
    digitalWrite(14, HIGH);
    delay(18);
    digitalWrite(14, LOW);
  }

    if (pitch_name(pitch) == "E") {
    digitalWrite(8, HIGH);
    delay(18);
    digitalWrite(8, LOW);
  }

    if (pitch_name(pitch) == "F") {
    digitalWrite(7, HIGH);
    delay(18);
    digitalWrite(7, LOW);
  }

    if (pitch_name(pitch) == "F#") {
    digitalWrite(15, HIGH);
    delay(18);
    digitalWrite(15, LOW);
  }

    if (pitch_name(pitch) == "G") {
    digitalWrite(5, HIGH);
    delay(18);
    digitalWrite(5, LOW);
  }

    if (pitch_name(pitch) == "G#") {
    digitalWrite(4, HIGH);
    delay(18);
    digitalWrite(4, LOW);
  }

    if (pitch_name(pitch) == "A") {
    digitalWrite(3, HIGH);
    delay(18);
    digitalWrite(3, LOW);
  }

    if (pitch_name(pitch) == "A#") {
    digitalWrite(2, HIGH);
    delay(18);
    digitalWrite(2, LOW);
  }


    if (pitch_name(pitch) == "B") {
    digitalWrite(13, HIGH);
    delay(18);
    digitalWrite(13, LOW);
  }
  
//  digitalWrite(LED_BUILTIN, HIGH); 
//  Serial.print("Note On: ");
//  Serial.print(pitch_name(pitch));
//  Serial.print(pitch_octave(pitch));
//  Serial.print(", channel=");
//  Serial.print(channel);
//  Serial.print(", velocity=");
//  Serial.println(velocity);
}

void noteOff(byte channel, byte pitch, byte velocity) {
//  digitalWrite(LED_BUILTIN, LOW); 

//  Serial.print("Note Off: ");
//  Serial.print(pitch_name(pitch));
//  Serial.print(pitch_octave(pitch));
//  Serial.print(", channel=");
//  Serial.print(channel);
//  Serial.print(", velocity=");
//  Serial.println(velocity);
}

const char* pitch_name(byte pitch) {
  static const char* names[] = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
  return names[pitch % 12];
}

int pitch_octave(byte pitch) {
  return (pitch / 12) - 1;
}
