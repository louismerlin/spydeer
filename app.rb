class Spydeer < Sinatra::Base
  get '/' do
    @mac_address = Device.all.map{|d| d.mac_address}
    erb :'public/index', :layout => :'public/layout'
  end

  get '/admin' do
    protected!
    @undefined_devices = Device.where(:human_id=>nil)
    erb :'admin/index', :layout => :'admin/layout'
  end


  ## HUMAN ADMINISTRATION
  get '/admin/humans' do
    protected!
    erb :'admin/humans', :layout => :'admin/layout'
  end

  get '/admin/humans/:id' do
    protected!
    @human = Human[params[:id].to_i]
    if @human!=nil
      @human.first_name + " " + @human.last_name
    end

  end

  post '/admin/humans/new' do
    protected!
    if !(params[:first_name]=="" && params[:last_name]=="")
      Human.new(first_name:params[:first_name], last_name:params[:last_name]).save
    end
    redirect back
  end

  get '/admin/humans/edit/:id' do
    protected!
    @human = Human[params[:id].to_i]
    erb :'admin/humans/edit', :layout => :'admin/layout'
  end

  post '/admin/humans/edit/:id' do
    protected!
    if !(params[:first_name]=="" && params[:last_name]=="") && Human.get(params[:id].to_i)!=nil
      Human[params[:id].to_i].update(first_name:params[:first_name], last_name:params[:last_name]).save
    end
    redirect back
  end

  get '/admin/humans/delete/:id' do
    protected!
    if Human[params[:id]]!=nil
      Human[params[:id]].destroy
    end
    redirect back
  end

  ## DEVICE ADMINISTRATION

  get '/admin/devices/:id' do
    protected!

  end

  get '/admin/devices/delete/:id' do
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
  ip = `ip addr | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'`
  return arp.split(/\n/).select{|l| l[0]==ip[0] && l[1]==ip[1] && l[2]==ip[2]}.map{|l| l.split(' ')[1]}
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
  macs.each_with_index{|m,i| create_device(m)}
  update_presence(macs)
end

hack_the_internet

scheduler = Rufus::Scheduler.new

scheduler.every '15s' do
  hack_the_internet
end
