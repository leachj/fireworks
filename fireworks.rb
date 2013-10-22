require 'sinatra'
require 'pi_piper'
require './dmx'
include PiPiper

armingSwitch = PiPiper::Pin.new(:pin => 3, :direction => :in, :pull => :up)
fireButton = PiPiper::Pin.new(:pin => 2, :direction => :in, :pull => :up)

fireButtonLight = PiPiper::Pin.new(:pin => 8, :direction => :out)
fireRelay = PiPiper::Pin.new(:pin => 7, :direction => :out)

dmx = Dmx.new({:numbers => 1, :litebar => 8})
number = NumberDisplay.new(dmx,:numbers)
litebar = LiteBar.new(dmx,:litebar)

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
     fireRelay.on
     sleep 5
     fireRelay.off
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
	PiPiper::Pin.new(:pin => 27, :direction => :out),
	PiPiper::Pin.new(:pin => 22, :direction => :out),
	PiPiper::Pin.new(:pin => 18, :direction => :out),
	PiPiper::Pin.new(:pin => 23, :direction => :out),
	PiPiper::Pin.new(:pin => 24, :direction => :out),
	PiPiper::Pin.new(:pin => 25, :direction => :out)
]

polarityChannel = pins[0]
selectorChannel = pins[1]
firstChannel = pins[2]
secondChannel = pins[3]

polarityBox = pins[7]
selectorBox = pins[6]
firstBox = pins[5]
secondBox = pins[4]


get '/select/:box/:channel/:polarity' do

    if armed
        fireButtonLight.on
     end
     box = "#{params[:box]}".to_i
     channel = "#{params[:channel]}".to_i
     polarity = "#{params[:polarity]}".to_i
     pins.each { |pin| pin.off }

     if(box > 2)
	selectorBox.off
     	if((box % 2) == 0)
		secondBox.off
	else
		secondBox.on
	end
     else
	selectorBox.on
     	if((box % 2) == 0)
		firstBox.off
	else
		firstBox.on
	end
     end

     if(channel > 2)
        selectorChannel.on
        if((channel % 2) == 0)
                secondChannel.on
        else
                secondChannel.off
        end
     else
        selectorChannel.off
        if((channel % 2) == 0)
                firstChannel.on
        else
                firstChannel.off
        end
     end

     if(polarity > 1)
	polarityBox.off
	polarityChannel.on
     else
	polarityBox.on
	polarityChannel.off
     end

    selected = true
    "selected box: #{box} channel: #{channel}"

end


