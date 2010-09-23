require 'rubygems'
require 'gosu'

class GameWindow < Gosu::Window
	def initialize
		super(640, 480, false)
		self.caption = "Gosu Tutorial Game"
		
		@song = Gosu::Song.new(self, "tylerk_-_a_bag_full_of_lunch.ogg")
		
		@manLeft = Gosu::Image.new(self, "starman_left.png", false)
		@manRight = Gosu::Image.new(self, "starman_right.png", false)
		
		@asteroid = Gosu::Image.new(self, "asteroid.png", false)
		@star = Gosu::Image.new(self, "star.png", false)
		@stars = []
		@asteroids = []
		@timer = 10
		@timerStart = 10
		
		@health = 3
		@caught = 0
		@font = Gosu::Font.new(self, Gosu::default_font_name, 20)
		
		@curImg = @manLeft
		@manX, @manY = 25, 340
	end

	def update
		@song.play(true)
		
		if button_down? Gosu::Button::KbLeft
			@manX = @manX - 2
			@curImg = @manLeft
		end
		
		if button_down? Gosu::Button::KbRight
			@manX = @manX + 2
			@curImg = @manRight
		end
		
		@timer = @timer - 1
		if @timer.zero?
			if rand(2).zero?
				@stars << [Gosu::random(10, 620), -10, Gosu::random(1,3)]
			else
				@asteroids << [Gosu::random(10, 620), -10, Gosu::random(1,3)]
			end
			@timer = @timerStart
		end
		
		for star in @stars
			star[0] = star[0] - 1
			star[1] = star[1] + star[2]
			
			if star[1] > 350 and star[1] < 400 and star[0] > @manX - 20 and star[0] < @manX + 20
				star[1] = 480
				@caught = @caught + 1
			end
		end
		
		for ass in @asteroids
			ass[0] = ass[0] - 1
			ass[1] = ass[1] + ass[2]
			
			if ass[1] > 350 and ass[1] < 400 and ass[0] > @manX - 20 and ass[0] < @manX + 20
				ass[1] = 480
				@health = @health - 1
			end
		end
		
		@stars.delete_if{|s| s[1] > 480}
		@asteroids.delete_if{|s| s[1] > 480}
	end

	def draw
		self.draw_quad(0,0, 0xff0b1728,
						640, 0, 0xff0b1728,
						640, 480, 0xff0b1728,
						0, 480, 0xff0b1728, -3)
		self.draw_quad(0,400, 0xff0b2228,
						640, 400, 0xff0b2228,
						640, 480, 0xff0b2228,
						0, 480, 0xff0b2228, -1)
		@curImg.draw( @manX, @manY + Gosu::offset_y(@manY%180, 10), 0)
		
		for star in @stars
			@star.draw( star[0], star[1], -2)
		end
		for ass in @asteroids
			@asteroid.draw( ass[0], ass[1], -2)
		end
		
		@font.draw("Stars: #{@caught}", 10, 10, 1, 1.0, 1.0, 0xffffff00)
		@font.draw("Life: #{@health}", 10, 30, 1, 1.0, 1.0, 0xffff0000)
	end
end

window = GameWindow.new
window.show