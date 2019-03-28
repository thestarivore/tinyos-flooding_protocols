# README

- Virtual machine with Tinyos and Cooja (simulator) [here](http://home.deib.polimi.it/redondi/IoT/IOT-ubuntu.ova), reuploaded [here](https://mega.nz/#!DFhAjI7I!K-atZGEu6Xm9JS-P3jGtSe7utK3DV6UuFg0XklI6LNw)
- run Cooja to start the simulation placed in the "simulations" folder

## Useful commands
- **export PACK_SIZE=N**: to set the size of the packet. The total size of the packet will be N + 1 bytes.
- **make telosb**: it compiles the code. The resulting file "main.exe" can then be used in the simulator (add a Sky Mote mote and use this file)
- **makeboth.sh**: compile both node and sink

## Useful links
- http://tinyos.stanford.edu/tinyos-wiki/index.php/TinyOS_Toolchain
- http://tinyos.stanford.edu/tinyos-wiki/index.php/Mote-mote_radio_communication
- https://stackoverflow.com/questions/3617950/tinyos-reception-after-second-reply-doesnt-work
- [UDGM](https://github.com/contiki-os/contiki/blob/master/tools/cooja/java/org/contikios/cooja/radiomediums/UDGM.java#L265)