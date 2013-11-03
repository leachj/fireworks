require 'data_mapper'

class Firework
  include DataMapper::Resource
 
  property :id,             Serial
  property :fired,        Boolean
  property :selected,        Boolean
  property :description,    Text, :required => true
  property :size,    Enum[:S, :M, :L, :XL]
  property :box,    Integer, :required => true, :format => /[1234]/, :unique_index => :u
  property :channel,    Integer, :required => true, :format => /[1234]/, :unique_index => :u
  property :polarity,    Integer, :required => true, :format => /[12]/, :unique_index => :u
 
  def select(pins)

    polarityChannel = pins[0]
    selectorChannel = pins[1]
    firstChannel = pins[2]
    secondChannel = pins[3]

    polarityBox = pins[7]
    selectorBox = pins[6]
    firstBox = pins[5]
    secondBox = pins[4]

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

end

end
