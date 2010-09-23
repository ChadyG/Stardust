#	Ludum Dare 14
#	"Walla Zombies"
#
#	Chad Godsey
#	April 18, 2009
#
#	Utility.rb contains extra classes for use in the game

def clamp(num, a, b)
	return a if num < a
	return b if num > b
	return num
end

class Array
	def method_missing(method, *arg)
		self.each { |item| item.send(method, *arg) }
	end
end

class FPS_Tracker
	attr_reader :fps
	def initialize
		@fps = 0
		@curTicks = 0
		@curSecond = Gosu::milliseconds / 1000
	end
	
	def register_tick
		@curTicks += 1
		current_second = Gosu.milliseconds / 1000
		if current_second != @curSecond
			@curSecond = current_second
			@fps = @curTicks
			@curTicks = 0
		end
	end
end

class Particle
	
	def initialize( x, y, dx, dy)
		@x, @y, @dx, @dy = x, y, dx, dy
		@z, @dz = 2, 0#1
	end
	
	def update
		@x += @dx
		@y += @dy
		@z += @dz
		#@dz -= 0.1
	end
	
	def draw(image, scale, color, layer = 0)
		angle = Gosu::angle( @x, @y, @x + @dx, @y + @dy)
		image.draw_rot( @x, @y, layer, angle, 0.5, 0.5, scale, scale, Gosu::Color.new(100, 0, 0, 0))
		image.draw_rot( @x, @y-@z, layer, angle, 0.5, 0.5, scale, scale, color)
	end
end

class Explosion
	attr_reader :health, :y
	
	def initialize( x, y, color, window)
		@y = y
		@@particle ||= Gosu::Image.new(window, 'particle.png', true)
		
		@color = color
		@scale = rand + 0.75
		@health = 50
		@particles = []
		1.upto(10) do |n|
			ang = 360*n/10
			dist = (rand(2)+1)/3.0
			@particles << Particle.new(x, y, Gosu::offset_x( ang, dist), Gosu::offset_y( ang, dist) )
		end
	end
	
	def update(window)
		@health -= 1
		@particles.update
		@scale -= 0.01
	end
	
	def draw(layer)
		@particles.draw(@@particle, @scale, @color, layer)
	end
	
end

class Image < Gosu::Image
	attr_accessor :scale, :x, :y, :z, :red, :blue, :green, :alpha, :centerX, :centerY, :angle
	
	def init
		@scale = 1.0
		@x = 0
		@y = 0
		@z = 0
		@red = 255
		@blue = 255
		@green = 255
		@alpha = 255
		@angle = 0
		@centerX = 0.0
		@centerY = 0.0
	end
	
	def quick_draw
		self.draw_rot( @x, @y, @z, 
			@angle, @centerX, @centerY, 
			@scale, @scale, 
			Gosu::Color.new(@alpha, @red, @green, @blue))
	end
	
	def zoom(amount = 0.01)
		@scale = @scale + amount
	end
	
	def fade(amount = 1)
		@alpha = clamp(@alpha + amount, 0, 255)
	end
	
	def zeroAngle
		@angle = @angle.zero? ? @angle : @angle > 0 ? @angle -0.1 : @angle + 0.1
	end
end


class GameState
	
	def initialize(window)
	end
	
	def button_down(id)
	end
	
	def button_up(id)
	end
	
	def update
	end
	
	def draw
	end

end