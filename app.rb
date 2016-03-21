class Spyder < Sinatra::Base
  get '/' do
    @mac_address = Device.all.map{|d| d.mac_address}
    erb :'public/index', :layout => :'public/layout'
  end

  get '/admin' do
    protected!
    @undefined_devices = Device.where(:human_id=>nil)
    erb :'admin/index', :layout => :'admin/layout'
  end

  post '/admin/human' do
    protected!
  end

  post '/admin/device' do
    protected!
  end

  get '/admin/login' do
    erb :'admin/login', layout: :'admin/layout'
  end

  post '/admin/login' do
    if params[:username] == CONFIG['admin']['id'] && params[:password] == CONFIG['admin']['password']
      session[:logged] = 'admin_true'
      redirect '/admin'
    else
      redirect '/admin/login'
    end
  end

  get '/admin/logout' do
  session.clear
  redirect '/'
end




  helpers do
    def protected!
      if authorized?
        true
      else
        redirect '/admin/login'
      end
    end

    def authorized?
      if session[:logged] == 'admin_true'
        true
      else
        false
      end
    end
  end

end

def arp_mac_addr()
  arp = `sudo arp-scan -l`
  return arp.split(/\n/).select{|l| l[0]=='1' && l[1]=='2' && l[2]=='8'}.map{|l| l.split(' ')[1]}
end

def create_device(mac)
  if Device.first(:mac_address => mac)==nil
    dev = Device.new(mac_address:mac).save
    dev.add_presence(Presence.new(:start_date=>Time.now()).save)
    dev.is_present = true
  end
end

def update_presence(macs)
  Device.all.each{|d|
    if macs.include?(d.mac_address) && d.presence.last() != nil && d.presence.last().end_date != nil
      d.add_presence(Presence.new(:start_date=>Time.now()).save)
      d.is_present = true
      if d.human != nil
        d.human.is_present = true
      end
    elsif !macs.include?(d.mac_address) && d.presence.last() != nil && d.presence.last().end_date != nil
      d.presence.last().end_date = Time.now()
      d.is_present = false
      if d.human != nil
        if d.human.devices.all?{|d| !d.is_present}
          d.human.is_present = false
        end
      end
      d.save
    end
  }

  #puts "hello"
  #puts dev.presence.last().start_date
end

def hack_the_internet
  macs = arp_mac_addr.uniq
  macs.each_with_index{|m,i| create_device(m);puts i}
  update_presence(macs)
end

hack_the_internet

scheduler = Rufus::Scheduler.new

scheduler.every '15s' do
  hack_the_internet
end
