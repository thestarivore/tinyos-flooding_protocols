#include <stdio.h>
#include "Node.h"
#include <stdlib.h>

module NodeC @safe() {
  uses {
    // Timer used to wait a random delay before reforwading the packets
    interface Timer<TMilli> as Timer0; 
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
  uint16_t packet_id;
  uint16_t delay;
  bool locked;                      //Node is locked between the time that it starts sending and the time has finished the operation
  
  /* 
  * Events
  */  
  // event fired when the device is booted
  event void Boot.booted() {
    call AMControl.start();
    srand(TOS_NODE_ID);       // Initialization, should only be called once. The seed can't be the time(NULL) so we use the Node's ID as seed
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
      if (nm->packet_id <= packet_id) {
        // packet already received, do nothing --> abort packet sending on timer 
        printf("NodeC: Node %d already received the packet %d.\n", TOS_NODE_ID, nm->packet_id);

        //If the same message arrived while we were waiting for timer countdown then abort
        if(nm->packet_id == packet_id){
          printf("NodeC: P: %d ABORTING packet %d reforwading.\n", TOS_NODE_ID, nm->packet_id);
          call Timer0.stop();
          locked = FALSE;
        }
      } else { 
        if (locked) {
          return bufPtr;
          printf("NodeC: Radio on %d it locked.\n", TOS_NODE_ID);
        } else {
          //Lock even while waiting for the timer
          locked = TRUE;

          printf("NodeC: Node %d received the new packet %d.\n", TOS_NODE_ID, nm->packet_id);
          delay = 500 + (rand() % 500);
          printf("NodeC: Node %d forwad delayed for %d ms.\n", TOS_NODE_ID, delay);
          call Timer0.startOneShot(delay); 
          packet = bufPtr;
          packet_id = nm->packet_id;
        }
      }
    }
    return bufPtr;
  }

  // event fired when the timer is done
  event void Timer0.fired() {
    if (call AMSend.send(AM_BROADCAST_ADDR, packet, sizeof(node_msg_t)) == SUCCESS) {
      printf("NodeC: P: %d broadcasting packet %d.\n", TOS_NODE_ID, packet_id);
    } else {
      printf("NodeC: An error occured during the broadcast from %d.\n", TOS_NODE_ID);
    }
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
