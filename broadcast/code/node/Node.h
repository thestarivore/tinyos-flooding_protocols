#ifndef NODE_H
#define NODE_H

typedef nx_struct node_msg {
  nx_uint16_t packet_id;
} node_msg_t;

enum {
  AM_RADIO_NODES = 6,
};

#endif
