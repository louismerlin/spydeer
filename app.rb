class Spyder < Sinatra::Base
  get '/' do
    #"<br>"  + $macs.join("</br><br>") + "</br>"
    @mac_address = $macs

    erb :'public/index', :layout => :'public/layout'


  end
end

def arp_mac_addr()
  arp = `sudo arp-scan -l`
  return arp.split(/\n/).select{|l| l[0]=='1' && l[1]=='9' && l[2]=='2'}.map{|l| l.split(' ')[1]}
end

$macs = arp_mac_addr
scheduler = Rufus::Scheduler.new

scheduler.every '15s' do
  $macs = arp_mac_addr
end
