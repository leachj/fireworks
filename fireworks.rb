require 'sinatra'
require 'pi_piper'
require './dmx'
require './firework'
include PiPiper
require 'rubygems'
require 'data_mapper'
require 'json'

armingSwitch = PiPiper::Pin.new(:pin => 3, :direction => :in, :pull => :up)
fireButton = PiPiper::Pin.new(:pin => 2, :direction => :in, :pull => :up)
checkPin = PiPiper::Pin.new(:pin => 10, :direction => :in)

fireButtonLight = PiPiper::Pin.new(:pin => 8, :direction => :out)
fireRelay = PiPiper::Pin.new(:pin => 7, :direction => :out)

dmx = Dmx.new({:numbers => 1, :litebar => 8})
number = NumberDisplay.new(dmx,:numbers)
litebar = LiteBar.new(dmx,:litebar)
countdown = true
pins = [PiPiper::Pin.new(:pin => 4, :direction => :out),
	PiPiper::Pin.new(:pin => 17, :direction => :out),
	PiPiper::Pin.new(:pin => 27, :direction => :out),
	PiPiper::Pin.new(:pin => 22, :direction => :out),
	PiPiper::Pin.new(:pin => 18, :direction => :out),
	PiPiper::Pin.new(:pin => 23, :direction => :out),
	PiPiper::Pin.new(:pin => 24, :direction => :out),
	PiPiper::Pin.new(:pin => 25, :direction => :out)
]


DataMapper.setup(:default, 'sqlite:project.db')
DataMapper.auto_upgrade!

fireworks = Firework.all
fireworks.each {|f| f.status = :unknown}
fireworks.save!
armed = false
selected = nil

litebar.green()

PiPiper::after :pin => 3, :goes => :high do
Thread.new do
  puts "Disarmed"
  armed = false
  fireButtonLight.off
  litebar.green()
end
end

PiPiper::after :pin => 3, :goes => :low do
Thread.new do
  puts "Armed"
  armed = true
  if selected
     fireButtonLight.on
  end

  litebar.red()
end
end

PiPiper::after :pin => 2, :goes => :low do
Thread.new do
  puts "Fire button pressed"
  if armed and selected
     selected.fired = true
     puts "Fire!!!!"
     fireButtonLight.off
     if countdown
	5.downto(0).each do |n|
	   puts n
   	   number.display(n)
	   sleep 1
        end
        number.clear()
     end
     fireRelay.on
     sleep 5
     fireRelay.off
     
     selected.save
     selected = nil
  elsif armed
    puts "no firework selected"
  else
    puts "not armed"
  end
end
end

get "/fireworks/countdown" do
	countdown = (countdown)?false:true
	redirect to('/fireworks')
end	

get "/fireworks/check" do
	
	fireworks = Firework.all
	fireworks.each do |firework|
		firework.select(pins)
		sleep 1
		checkPin.read
		if(checkPin.off?)
			firework.status = :ok
			puts "OK"
		else
			firework.status = :error
			puts "Not OK"
		end
	end
	pins.each { |pin| pin.off }
	fireworks.save!
	selected = nil
	redirect to('/fireworks')

end

get "/fireworks" do
	@fireworks = Firework.all.sort_by do |x| 
	    if(x.fired)
		100
	    elsif(x==selected)
		0
	    else
		[:S, :M, :L, :XL].index(x.size) + 1
	    end
	end
	@selected = selected
	@countdown = countdown
	erb :list
end

get "/fireworks/:id/select" do

     @firework = Firework.get(params[:id])
     if(@firework.fired)
	return
     end
     if armed
        fireButtonLight.on
     end
     pins.each { |pin| pin.off }
     @firework.select(pins)
     selected = @firework
     redirect to('/fireworks')
end

get "/fireworks/add" do
	erb :add
end

post "/fireworks" do
	@firework = Firework.new
	@firework.fired = false
	@firework.description = params[:description]
	@firework.box = params[:box]
	@firework.channel = params[:channel]
	@firework.polarity = params[:polarity]
	@firework.size = params[:size].to_sym
	if @firework.save
	    "Firework added"
	else
	    "Firework not added"
	end
end
get "/fireworks/:id/delete" do
	@firework = Firework.get(params[:id])
	@firework.destroy
	redirect to('/fireworks')
end

