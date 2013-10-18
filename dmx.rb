class Dmx

	def initialize(ids)
		@channels = Hash[ids.map{|k,id| [k,id - 1] } ]
		@values = Array.new(512,0)
	end

	def set(id, newValues)

		@values[@channels[id],newValues.count] = newValues
		output()
	end

	def output
		`ola_set_dmx -u 1 -d #{@values.join(",")}`
	end

end

class LiteBar

	def initialize(dmx, id)
		@dmx = dmx
		@id = id
	end
	
	def red
		@dmx.set(@id, [86,0,255,0,0])
	end
	
	def green
		@dmx.set(@id, [86,0,0,255,0])
	end

end

class NumberDisplay

	def initialize(dmx, id)
		@dmx = dmx
		@id = id
	end

	def display(number)
		
		if(number == 1)
			levels = set([:bottom_right, :top_right])
		end
		if(number == 2)
			levels = set([:top, :bottom, :top_right, :middle, :bottom_left])
		end	
		if(number == 3)
			levels = set([:top, :bottom, :top_right, :middle, :bottom_right])
		end	
		if(number == 4)
			levels = set([:top_left, :top_right, :middle, :bottom_right])
		end	
		if(number == 5)
			levels = set([:top, :bottom, :top_left, :middle, :bottom_right])
		end	
		@dmx.set(@id,levels)

	end

	def clear
		@dmx.set(@id,[0,0,0,0,0,0])
	end

	def set(segments, value = 255)
		values = []
		values << (segments.include?(:bottom_left) ? value : 0)
		values << (segments.include?(:bottom_right) ? value : 0)
		values << (segments.include?(:top_left) ? value : 0)
		values << ((segments.include?(:top) or segments.include?(:bottom)) ? value : 0)
		values << (segments.include?(:middle) ? value : 0)
		values << (segments.include?(:top_right) ? value : 0)
		values
	end	

end

