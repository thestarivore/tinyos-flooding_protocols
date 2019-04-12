configuration NodeAppC {}

implementation {
  components NodeC;
  components MainC;
  components new AMSenderC(AM_RADIO_NODES);
  components new AMReceiverC(AM_RADIO_NODES);
  components ActiveMessageC;
  components SerialPrintfC;
  components new PoolC(message_t, 10) as Pool0;

  NodeC.Boot -> MainC.Boot;
  NodeC.AMSend -> AMSenderC;
  NodeC.Receive -> AMReceiverC;
  NodeC.AMControl -> ActiveMessageC;
  NodeC.Pool0 -> Pool0;
}