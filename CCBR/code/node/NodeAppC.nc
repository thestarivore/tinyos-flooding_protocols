configuration NodeAppC {}

implementation {
  components NodeC;
  components MainC;
  components new AMSenderC(AM_RADIO_NODES);
  components new AMReceiverC(AM_RADIO_NODES);
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components SerialPrintfC;
  components new PoolC(message_t, 10) as Pool0;

  NodeC.Boot -> MainC.Boot;
  NodeC.AMSend -> AMSenderC;
  NodeC.Receive -> AMReceiverC;
  NodeC.Timer0 -> Timer0;
  NodeC.AMControl -> ActiveMessageC;
  NodeC.Packet -> AMSenderC;
  NodeC.Pool0 -> Pool0;
}