require 'sinatra'
require 'pi_piper'
require './dmx'
include PiPiper
require 'rubygems'
require 'data_mapper'
require 'json'

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


DataMapper.setup(:default, 'sqlite:project.db')

class Task
  include DataMapper::Resource
 
  property :id,             Serial
  property :fired,        Boolean
  property :description,    Text, :required => true
  property :box,    Integer, :required => true, :format => /[1234]/, :unique_index => :u
  property :channel,    Integer, :required => true, :format => /[1234]/, :unique_index => :u
  property :polarity,    Integer, :required => true, :format => /[12]/, :unique_index => :u
 
end
DataMapper.auto_upgrade!


before do
	content_type 'application/json'
end

get "/" do
	content_type 'html'
	erb :index
end
get "/tasks" do
	@tasks = Task.all
	@tasks.to_json
end

get "/tasks/:id/select" do

	@task = Task.get(params[:id])
     box = @task.box
     channel = @task.channel
     polarity = @task.polarity
     if armed
        fireButtonLight.on
     end
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
    "selected box: #{box} channel: #{channel} polarity: #{polarity}"
end

post "/tasks/new" do
	@task = Task.new
	@task.fired = false
	@task.description = params[:description]
	@task.box = params[:box]
	@task.channel = params[:channel]
	@task.polarity = params[:polarity]
	if @task.save
		{:task => @task, :status => "success"}.to_json
	else
		{:task => @task, :status => "failure"}.to_json
	end
end
put "/tasks/:id" do
	@task = Task.find(params[:id])
	@task.fired = params[:fired]
	@task.description = params[:description]
	@task.box = params[:box]
	@task.channel = params[:channel]
	@task.polarity = params[:polarity]
	if @task.save
		{:task => @task, :status => "success"}.to_json
	else
		{:task => @task, :status => "failure"}.to_json
	end
end
delete "/tasks/:id" do
	@task = Task.get(params[:id])
	if @task.destroy
		{:status => "success"}.to_json
	else
		{:status => "failure"}.to_json
	end
end

def select(box, channel, polarity)
	
    if armed
        fireButtonLight.on
     end
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
    "selected box: #{box} channel: #{channel} polarity: #{polarity}"

end

get '/select/:box/:channel/:polarity' do

     box = "#{params[:box]}".to_i
     channel = "#{params[:channel]}".to_i
     polarity = "#{params[:polarity]}".to_i
     select(box, channel, polarity)

end


