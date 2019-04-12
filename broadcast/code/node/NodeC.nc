#include <stdio.h>
#include "Node.h"

module NodeC @safe() {
  uses {
    interface Boot;
    interface Receive;
    interface AMSend;
    interface SplitControl as AMControl;
    interface Pool<message_t> as Pool0;
  }
}

implementation {

  /* 
  * Local variables
  */ 
  message_t* packet;
  bool locked;
  uint8_t counter = 0;
  
  /* AM_RADIO_NODESAM_RADIO_NODES
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
    printf("NodeC: Received packet of length %d\n", len);

    if (len != sizeof(node_msg_t) || call Pool0.empty()) {
      printf("NodeC: Packet error\n");
      return bufPtr;
    } else {
      node_msg_t* nm = (node_msg_t*) payload;
      
      /*
      * check if the message was already received,
      * if so, do nothing otherwise, broadcast the packet
      */
      if (nm->packet_id <= counter) {
        // packet already received, do nothing
        printf("NodeC: Already received the packet %d\n", nm->packet_id);
        return bufPtr;
      } else {

        // check if the radio is not locked
        if (locked) {
          printf("NodeC: Radio is locked\n");
          return bufPtr;
        } else {
          counter++;
          printf("NodeC: Received the new packet %d\n", nm->packet_id);

          // broadcast the packet
          packet = bufPtr;

          if (call AMSend.send(AM_BROADCAST_ADDR, packet, sizeof(node_msg_t)) == SUCCESS) {
            printf("NodeC: Broadcasting packet %d\n", nm->packet_id);
            locked = TRUE;
          } else {
            printf("NodeC: An error occured during the broadcast\n");
          } 
          return call Pool0.get();
        }
      }
    }
  }

  // event fired when send is done
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (packet == bufPtr) {
      if(error == SUCCESS){
        printf("NodeC: Packet sent\n");
      } else {
        printf("NodeC: Packet send error\n");
      }
      locked = FALSE;
      call Pool0.put(bufPtr);
    }
  }
}
