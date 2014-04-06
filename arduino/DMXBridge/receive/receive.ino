// - - - - -
// DMXBridge.ino:
// Application for sending DMX over an 2.4 GHz wireless link
// using Arduinos, DMX shields and nRF24L01+ modules.
// Copyright (c) 2013 by Matthias Hertel, http://www.mathertel.de
// This work is licensed under a BSD style license. See http://www.mathertel.de/License.aspx
//
// Documentation and samples are available at http://www.mathertel.de/Arduino
// 01.06.2013 creation of the DMXBridge project.
// 28.06.2013 prototype is running.
// 01.07.2013 creation of test sketches.
//
// This is sketch is part of the DMXBridge project for sending DMX values
// over a 2.4 GHz wireless link using Arduinos, DMX shields and nRF24L01+ modules.
//
// This is an example sends and receives 3 values (non DMX)
// over the link for testing sender and receiver implementations
// and various options.
// The values can be watched at the PWM outputs of the Arduino Board.

// Prerequisites:
// * Import the DMXSerial library into the Sketches/libraries folder.
//   http://www.mathertel.de/Arduino/DMXSerial.aspx
// * Import the RF24 library into the Sketches/libraries folder.
//   https://github.com/gcopeland/RF24 (use the [Download ZIP] button on the right)
// * compile the Sketch to see if everything is there.
// - - - - -


#include <DMXSerial.h>
//#define DMXSERIAL_MAX 512

#include <SPI.h>
#include <RF24.h>

// Set up role.  This sketch uses the same software for all the nodes.
// Change the following definition before compiling/uploading to the nodes.

// Hardware and Topology configuration

// Set up nRF24L01 radio on SPI bus plus pins 7 & 8
RF24 radio(8,7);

// Single radio pipe address for the 2 nodes to communicate.
const uint64_t PIPE = 0xE8E8F0F0E1LL;


// PAYLOAD TYPE
// structure of the payload / a transmitted package
struct payload_t {
  uint8_t messageNr;
  uint8_t start8;        // dmx start address of data = start8 * 8
  uint8_t dmxValues[8];  // dmxdata[8 * start8 + 1] .. dmxdata[8 * start8 + 8]
}; // payload_t


uint8_t dmxSentData[DMXSERIAL_MAX+1];
uint8_t serialDmx[DMXSERIAL_MAX+1];

int     fastIdx; // last checked index position using the fast mode.
int     slowIdx; // last checked index position using the slow mode.
int     serialIdx; // Index of serial datas read

unsigned long nextSlow = 0; // 
uint8_t messageNr = 0;


// The role of the current running sketch
boolean isReceiver = true;

// setup the Board and nRF24L01
void setup(void)
{
  int ix;
#if 0
  // Print preamble
  Serial.begin(115200);
  Serial.println("DMXBRIDGE RF24 DMX Transceiver");
#endif

  // Setup and configure rf radio

  radio.begin();

  radio.setChannel(101);   // use channel 101
  radio.setDataRate(RF24_2MBPS); // use fastest transfer speed
  radio.setAutoAck(false); // use broadcast mode
  // receive NRF24L01 data ...
  radio.openReadingPipe(1,PIPE);
  radio.startListening();

#if 1
  // ... and send them as DMX packages.
  DMXSerial.init(DMXController);
  DMXSerial.write (1,200);
  DMXSerial.write (4,255);
  DMXSerial.write(3, 0);
  DMXSerial.write(5, 0);
  DMXSerial.write(2,0);
#endif

} // setup()




void loop(void)
{
  unsigned long now = millis();
  static uint8_t message_nr = 0;

  static uint32_t message_count = 0;
  payload_t payload;


  // Receiver role. Receive 

  // if there is data ready
  if (radio.available()) {

    // Fetch the payload, and see if this was ok.
    bool done = radio.read(&payload, sizeof(payload));

    if (done) {
      int i = payload.start8 * 8 + 1;
  
      for (int n = 0; n < 8; n++, i++)
        DMXSerial.write(i, payload.dmxValues[n]);
        //Serial.println("Recu");
    } // if
  } // if


} // loop()

// The End.
