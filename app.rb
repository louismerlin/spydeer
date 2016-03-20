class Spyder < Sinatra::Base
  get '/' do
    @mac_address = devices.map{|d| d.get(:mac_address)}

    erb :'public/index', :layout => :'public/layout'


  end
  get '/admin' do
    @undefined_devices = Device.where(:human_id=>nil)
    erb :'admin/index', :layout => :'admin/layout'




  end
end

def arp_mac_addr()
  arp = `sudo arp-scan -l`
  return arp.split(/\n/).select{|l| l[0]=='1' && l[1]=='9' && l[2]=='2'}.map{|l| l.split(' ')[1]}
end

def add_presence(mac)
  if Device.first(:mac_address => mac)==nil
    dev = Device.new(mac_address:mac).save
  else
    dev = Device.first(:mac_address => mac)
  end
end

def hack_the_internet
  macs = arp_mac_addr.uniq
  macs.each{|m| add_presence(m)}
end

hack_the_internet

scheduler = Rufus::Scheduler.new

scheduler.every '15s' do
  hack_the_internet
end
