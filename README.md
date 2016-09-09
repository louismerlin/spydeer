# spydeer
Spydeer is a tool that logs the mac addresses connected to your wi-fi. You can then assign devices and names to the addresses and see who was connected when.

## How to use
Make sure you have *arp-scan* installed (this is what is used, with administrator privilege, to fetch the mac addresses.

You need to install *ruby*, too. Then, run `gem install sinatra sequel rufus-scheduler thin` and launch the server with `rackup` !!
