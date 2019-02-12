#ifndef NODE_H
#define NODE_H

typedef nx_struct node_msg {
  nx_uint8_t packet_id;
  nx_uint8_t packet_content[1];
} node_msg_t;

enum {
  AM_RADIO_NODES = 6,
};

#endif
