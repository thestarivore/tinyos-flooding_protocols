configuration NodeAppC {}

implementation {
  components NodeC;
  components MainC;
  components new AMSenderC(AM_RADIO_NODES);
  components new AMReceiverC(AM_RADIO_NODES);
  components ActiveMessageC;
  components SerialPrintfC;

  NodeC.Boot -> MainC.Boot;
  NodeC.AMSend -> AMSenderC;
  NodeC.Receive -> AMReceiverC;
  NodeC.AMControl -> ActiveMessageC;
  NodeC.Packet -> AMSenderC;
}