// - - - - -
// DMXBridge.ino:
// Application for sending DMX over an 2.4 GHz wireless link
// using Arduinos, DMX shields and nRF24L01+ modules.
// Copyrith (c) 2014  Xavier Pouyollon based on work from 
// Matthias Hertel, http://www.mathertel.de
// This work is licensed under a BSD style license. See http://www.mathertel.de/License.aspx
//
//
//
// Documentation and samples are available at http://www.mathertel.de/Arduino
// 01.06.2013 creation of the DMXBridge project.
// 28.06.2013 prototype is running.
// 01.07.2013 creation of test sketches.
//
// This is sketch is part of the DMXBridge project for sending DMX values
// over a 2.4 GHz wireless link using Arduinos, DMX shields and nRF24L01+ modules.
//
// Prerequisites:
// * Import the DMXSerial library into the Sketches/libraries folder.
//   http://www.mathertel.de/Arduino/DMXSerial.aspx
// * Import the RF24 library into the Sketches/libraries folder.
//   https://github.com/gcopeland/RF24 (use the [Download ZIP] button on the right)
// * compile the Sketch to see if everything is there.
// - - - - -



#define DMXSERIAL_MAX  512


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

#define WAIT_FRAME           0
#define READ_FULL_FRAME      1
#define READ_PARTIAL_FRAME   2

int state;

unsigned long nextSlow = 0; // 
uint8_t messageNr = 0;


// setup the Board and nRF24L01
void radiosetup(void)
{
  // Print preamble
  // Serial.begin(57600);
  // Serial.println("DMXBRIDGE RF24 DMX Transceiver");

  // Setup and configure rf radio
  radio.begin();

  radio.setChannel(101);   // use channel 101
  radio.setDataRate(RF24_2MBPS); // use fastest transfer speed
  radio.setAutoAck(false); // use broadcast mode
  // ... and send them into the air.
  radio.openWritingPipe(PIPE);
} // setup()

void setup(void) {
    Serial.begin(115200);
    fastIdx = 1;
    slowIdx = 1;
    serialIdx = 0;
    nextSlow = millis() + 2000;
    state = WAIT_FRAME;
    radiosetup();
}

// Send a part of the dmx values into the air.
// Send the package that includes the DMX channel idx.
// Take the values from the DMX input buffer and remember them in the dmxSentData array.
// Return the index of the next DMX channel not sent.
int SendBuffer (int idx)
{
  messageNr++;
  payload_t payload;
  
  int p = ((idx-1) % DMXSERIAL_MAX) / 8; // part to be sent
  int i = p*8 + 1;
  
  // populate payload
  payload.start8 = p;
  payload.messageNr = messageNr;
  for (int n = 0; n < 8; n++) {
    payload.dmxValues[n] = dmxSentData[i] = serialDmx[i];
    i++;
  } // for
  radio.write(&payload, sizeof(payload), true);
  return (i);
} // SendBuffer()


void loop(void)
{
  unsigned long now = millis();
  static uint8_t message_nr = 0;

  static uint32_t message_count = 0;
  payload_t payload;
      
  while (Serial.available()) {
    char c;
    c = Serial.read();

    switch (state) {
      case WAIT_FRAME:
        if (c == 'F') {
          state == READ_FULL_FRAME;
          serialIdx = 1;
        } else if (serialDmx[0] = 'P') {
          state == READ_PARTIAL_FRAME;
        } else {
          // Bogus state. Stay in WAIT_FRAME
          serialIdx = 0;
        } 
        break;
       case READ_FULL_FRAME:
         serialDmx[serialIdx] = c;
         serialIdx++;
         if (serialIdx == (DMXSERIAL_MAX+1)) {
              serialIdx = 0;
              state = WAIT_FRAME;
            }         
         break;
    } // End switch.
  }
  
  // DMX Sender role.  Receive each packet, dump it out, add ack payload for next time
  if (now > nextSlow) {
    // Send a package with the current values
    // even if they have changed or not every 2 seconds.
    slowIdx = SendBuffer(slowIdx);
    nextSlow = now + 2000;
    
  } else {      
    // Send the next package with changed values.
    // max. check next 20 values
    for (int n = 0; n <= 20; n++) {
      fastIdx = (fastIdx % DMXSERIAL_MAX) + 1;
      if (serialDmx[fastIdx] != dmxSentData[fastIdx]) {
        fastIdx = SendBuffer(fastIdx);
        break; // so good for now.
      } // if
    } // for
  } // if
} // loop()
// The End.
