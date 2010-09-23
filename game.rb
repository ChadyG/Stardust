require 'rubygems'
require 'gosu'
require 'utility.rb'

class GameWindow < Gosu::Window
	def initialize
		super(640, 480, false)
		self.caption = "Gosu Tutorial Game"
		
		@song = Gosu::Song.new(self, "tylerk_-_a_bag_full_of_lunch.ogg")
		
		@hit = Gosu::Sample.new(self, "hit.wav")
		@jump = Gosu::Sample.new(self, "jump.wav")
		@powerup = Gosu::Sample.new(self, "starcatch.wav")
		@death = Gosu::Sample.new(self, "death.wav")
		
		@manLeft = Gosu::Image.new(self, "starman_left.png", false)
		@manRight = Gosu::Image.new(self, "starman_right.png", false)
		
		@asteroid = Gosu::Image.new(self, "asteroid.png", false)
		@star = Gosu::Image.new(self, "star.png", false)
		@stars = []
		@asteroids = []
		@explosions = []
		@timer = 10
		@timerStart = 10
		
		@deathCounter = -1
		@deathStartCount = 20
		
		@lolrotate = 0
		@lolscale = 1.0
		
		@JumpHeld = false
		@manJumping = false
		@manJump = 0
		@manJumpStart = -12
		
		@health = 3
		@caught = 0
		@font = Gosu::Font.new(self, Gosu::default_font_name, 20)
		
		@curImg = @manLeft
		@manX, @manY = 25, 340
	end

	def update
		@song.play(true)
		
		unless @health.zero?
		
			if button_down? Gosu::Button::KbLeft
				@manX = @manX - 2
				@curImg = @manLeft
			end
			
			if button_down? Gosu::Button::KbRight
				@manX = @manX + 2
				@curImg = @manRight
			end
			
			if button_down? Gosu::Button::KbUp 
				unless @manJumping or @JumpHeld
					@manJump = @manJumpStart
					@manJumping = true
					@jump.play
				end
				@JumpHeld = true
			else
				@JumpHeld = false
			end
			
			if @manJumping
				@manJump = @manJump + 1
				@manY = @manY + @manJump
			end
			
			if @manY > 340
				@manJumping = false
				@manY = 340
			end
		
		else
			if @deathCounter == -1
				@manJumping = false
				@manY = 340
				@deathCounter = @deathStartCount
			end
			
			if @deathCounter.zero?
				@lolscale = @lolscale - 0.005
				@lolrotate = @lolrotate + 1
			else
				@deathCounter = @deathCounter - 1
			end
			
			if @lolscale < 0.0
				@lolrotate = 0
				@lolscale = 1.0
				
				@JumpHeld = false
				@manJumping = false
				@manJump = 0
				
				@stars = []
				@asteroids = []
				@timer = 10
		
				@deathCounter = -1
				
				@health = 3
				@caught = 0
				
				@curImg = @manLeft
				@manX, @manY = 25, 340
			end
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
			
			unless @health.zero?
				if star[1] > @manY + 10 and star[1] < @manY + 60 and star[0] > @manX - 20 and star[0] < @manX + 20
					star[1] = 480
					@caught = @caught + 1
					@powerup.play
					
					@explosions << Explosion.new( @manX+16, @manY+32, Gosu::Color.new(0xFF, 0xFF, 0xDD, 0x55), self)
				end
			end
		end
		
		for ass in @asteroids
			ass[0] = ass[0] - 1
			ass[1] = ass[1] + ass[2]
			
			unless @health.zero?
				if ass[1] > @manY + 10 and ass[1] < @manY + 60 and ass[0] > @manX - 20 and ass[0] < @manX + 20
					ass[1] = 480
					@health = @health - 1
					if @health.zero?
						@death.play 
					else
						@hit.play
					end
				end
			end
		end
		
		for exp in @explosions
			exp.update(self)
		end
		
		@stars.delete_if{|s| s[1] > 460 or s[0] < 5}
		@asteroids.delete_if{|s| s[1] > 460 or s[0] < 5}
		@explosions.delete_if { |exp| exp.health.zero? }
	end

	def draw
		scale(@lolscale) {
		rotate(@lolrotate, 320, 240) {
		
		self.draw_quad(0,0, 0xff0b1728,
						640, 0, 0xff0b1728,
						640, 480, 0xff0b1728,
						0, 480, 0xff0b1728, -3)
		self.draw_quad(0,400, 0xff0b2228,
						640, 400, 0xff0b2228,
						640, 480, 0xff0b2228,
						0, 480, 0xff0b2228, -1)
		if @health.zero?
			@manLeft.draw_rot( @manX, @manY + 60, 0, 90)
		else
			@curImg.draw( @manX, @manY + Gosu::offset_y(@manY%180, 10), 0)
		end
		
		for star in @stars
			@star.draw( star[0], star[1], -2)
		end
		for ass in @asteroids
			@asteroid.draw( ass[0], ass[1], -2)
		end
		for exp in @explosions
			exp.draw(1)
		end
		
		
		@font.draw("Stars: #{@caught}", 10, 10, 1, 1.0, 1.0, 0xffffff00)
		@font.draw("Life: #{@health}", 10, 30, 1, 1.0, 1.0, 0xffff0000)
		
		}
		}
	end
end

window = GameWindow.new
window.show