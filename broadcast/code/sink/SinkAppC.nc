configuration SinkAppC {}

implementation {
  components SinkC;
  components MainC;
  components new AMSenderC(AM_RADIO_NODES);
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components SerialPrintfC;

  SinkC.Boot -> MainC.Boot;
  SinkC.AMSend -> AMSenderC;
  SinkC.Timer0 -> Timer0;
  SinkC.AMControl -> ActiveMessageC;
  SinkC.Packet -> AMSenderC;
}