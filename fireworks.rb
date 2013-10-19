require 'sinatra'
require 'pi_piper'
require './dmx'
include PiPiper

armingSwitch = PiPiper::Pin.new(:pin => 1, :direction => :in, :pull => :up)
fireButton = PiPiper::Pin.new(:pin => 0, :direction => :in, :pull => :up)

fireButtonLight = PiPiper::Pin.new(:pin => 8, :direction => :out)

dmx = Dmx.new({:numbers => 1, :litebar => 8})
number = NumberDisplay.new(dmx,:numbers)
litebar = LiteBar.new(dmx,:litebar)

armed = false
selected = nil

litebar.green()

PiPiper::after :pin => 1, :goes => :high do
Thread.new do
  puts "Disarmed"
  armed = false
  fireButtonLight.off
  litebar.green()
end
end

PiPiper::after :pin => 1, :goes => :low do
Thread.new do
   puts "Armed"
  armed = true
  if selected
     fireButtonLight.on
  end

  litebar.red()
end
end

PiPiper::after :pin => 0, :goes => :low do
Thread.new do
  puts "Fire button pressed"
  if armed and selected
     puts "Fire!!!!"
     fireButtonLight.off
     number.display(5)
     sleep 1
     number.display(4)
     sleep 1
     number.display(3)
     sleep 1
     number.display(2)
     sleep 1
     number.display(1)
     sleep 1
     number.display(0)
     sleep 1
     number.clear()
     selected = nil
  elsif armed
    puts "no firework selected"
  else
    puts "not armed"
  end
end
end


pins = [PiPiper::Pin.new(:pin => 4, :direction => :out),
	PiPiper::Pin.new(:pin => 17, :direction => :out),
	PiPiper::Pin.new(:pin => 21, :direction => :out),
	PiPiper::Pin.new(:pin => 22, :direction => :out),
	PiPiper::Pin.new(:pin => 18, :direction => :out),
	PiPiper::Pin.new(:pin => 23, :direction => :out),
	PiPiper::Pin.new(:pin => 24, :direction => :out),
	PiPiper::Pin.new(:pin => 25, :direction => :out)
]


get '/select/:number' do

    if armed
        fireButtonLight.on
     end
     selected = #{params[:number]}
    "selected #{params[:number]}"

end


