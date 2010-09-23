#	Ludum Dare 14
#	"Walla Zombies"
#
#	Chad Godsey
#	April 17, 2009

require 'gosu'
require 'utility.rb'
require 'IntroState.rb'
require 'PlayState.rb'
require 'CreditsState.rb'
require 'PauseState.rb'

class MyWindow < Gosu::Window
	attr_reader :text
	
	def initialize
		super(640, 480, false, 20)
		self.caption = 'Walla Zombies!'
		@text = Gosu::Font.new(self, Gosu::default_font_name, 20)
		@states = []
		@states << Intro.new(self)
		
		@fpsTracker = FPS_Tracker.new
		
		@songLoop = Gosu::Song.new(self, 'sounds/RockLoop.ogg')
		@songIntro = Gosu::Song.new(self, 'sounds/RockIntro.ogg')
		@songIntro.play
	end
	
	def button_down(id)
		@states[-1].button_down(id)
	end
	
	def button_up(id)
		@states[-1].button_up(id)
	end
	
	def update
		@fpsTracker.register_tick
		@songLoop.play(true) unless @songIntro.playing? or @songLoop.playing?
		if @states.empty?
			close
		end
		
		if button_down? Gosu::Button::KbEscape
			close
		end
		
		@states[-1].update
	end
	
	def draw
		@text.draw( @fpsTracker.fps.to_s, 600, 5, 5)
		@states[-1].draw
	end
	
	def states_push(state)
		@states << state
	end
	
	def states_pop
		@states.pop
		close if @states.empty?
	end
	
	def states_replace(state)
		@states.pop
		@states << state
		close if @states.empty?
	end
end


w = MyWindow.new
w.show