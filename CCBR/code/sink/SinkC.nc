#include <stdio.h>
#include "Node.h"

module SinkC @safe() {
  uses {
    // timer used to wait until nodes are booted and for message propagation
    interface Timer<TMilli> as Timer0; 
    interface Boot;
    interface AMSend;
    interface SplitControl as AMControl;
    interface Packet;
  }
}

implementation {

  /* 
  * Local variables
  */
  message_t packet;
  bool locked;
  uint8_t counter = 1;

  /* 
  * Events
  */  
  // event fired when the device is booted
  event void Boot.booted() {
    call AMControl.start();
    printf("SinkC: Booting device %d.\n", TOS_NODE_ID);
  }

  // event fired when AM is started
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      // AM is started
      printf("SinkC: AM started on device %d.\n", TOS_NODE_ID);
      printf("SinkC: Start sending data.\n"); 

      // wait until all nodes are booted and are listening
      call Timer0.startPeriodic(60000);
    } else {
      // try to start AM another time
      call AMControl.start();
    }
  }

  // event fired when the timer is done
  event void Timer0.fired() {
    // build the packet
    node_msg_t* nm = (node_msg_t*) call Packet.getPayload(&packet, sizeof(node_msg_t));

    if (nm == NULL) {
      printf("SinkC: Error during the creation of the packet.\n");
      return;
    }

    nm->packet_id = counter;
    nm->packet_content[1] = counter;
    counter++;
    
    // send the packet
    if (locked) {
      printf("SinkC: Radio is locked.\n");
      // if radio is locked wait the next timer
      return;
    } else {
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(node_msg_t)) == SUCCESS) {
        printf("SinkC: P: Broadcasting packet %d.\n", nm->packet_id);
        locked = TRUE;
      }
    }
  }

  // event fired when AM is stopped
  event void AMControl.stopDone(error_t err) {
    // do nothing
  }

  // event fired when send is done
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    /* This test is needed because if two components wire to the same AMSend, both will receive a sendDone event after either component issues a send command. Since a component writer has no way to enforce that her component will not be used in this manner, a defensive style of programming that verifies that the sent message is the same one that is being signaled is required. From http://tinyos.stanford.edu/tinyos-wiki/index.php/Mote-mote_radio_communication */
    if (&packet == bufPtr) {
      printf("SinkC: Packet sent\n");
      locked = FALSE;
    } else {
      printf("SinkC: Packet error.\n");
    }
  }
}
