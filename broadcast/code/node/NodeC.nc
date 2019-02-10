#include <stdio.h>
#include "Node.h"

module NodeC @safe() {
  uses {
    interface Boot;
    interface Receive;
    interface AMSend;
    interface SplitControl as AMControl;
    interface Packet;
  }
}

implementation {

  /* 
  * Local variables
  */ 
  message_t* packet;
  bool locked;
  uint16_t counter = 0;
  
  /* 
  * Events
  */  
  // event fired when the device is booted
  event void Boot.booted() {
    call AMControl.start();
    printf("NodeC: Booting device %d.\n", TOS_NODE_ID);
  }

  // event fired when AM is started
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      // AM is started
      printf("NodeC: AM started on device %d.\n", TOS_NODE_ID);
    } else {
      // try to start AM another time
      call AMControl.start();
    }
  }

  // event fired when AM is stopped
  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  
  // event fired when a message is received
  /*
  * bufPtr: the received packet
  * payload: a pointer to the packet's payload
  * len: the length of the data region pointed to by payload
  * return a packet buffer for the stack to use for the next received packet.
  */
  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    printf("NodeC: Node %d received packet of length %d.\n", TOS_NODE_ID, len);

    if (len != sizeof(node_msg_t)) {
      return bufPtr;
    } else {
      node_msg_t* nm = (node_msg_t*) payload;

      /*
      * check if the message was already received,
      * if so, do nothing otherwise, broadcast the packet
      */
      if (nm->packet_id <= counter) {
        // packet already received, do nothing
        printf("NodeC: Node %d already received the packet %d.\n", TOS_NODE_ID, nm->packet_id);
      } else {
        printf("NodeC: Node %d received the new packet %d.\n", TOS_NODE_ID, nm->packet_id);

        // check if the radio is not locked
        if (locked) {
          return bufPtr;
          printf("NodeC: Radio on %d it locked.\n", TOS_NODE_ID);
        } else {
          // broadcast the packet
          counter++;

          packet = bufPtr;
          if (call AMSend.send(AM_BROADCAST_ADDR, bufPtr, sizeof(node_msg_t)) == SUCCESS) {
            printf("NodeC: P: %d broadcasting packet %d.\n", TOS_NODE_ID, nm->packet_id);
            locked = TRUE;
          } else {
            printf("NodeC: An error occured during the broadcast from %d.\n", TOS_NODE_ID);
          }
        }
      }
    }
    return bufPtr;
  }

  // event fired when send is done
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (packet == bufPtr) {
      printf("NodeC: Packet sent.\n");
      locked = FALSE;
    } else {
      printf("NodeC: Packet error.\n");
    }
  }

}
