#	Ludum Dare 14
#	"Walla Zombies"
#
#	Chad Godsey
#	April 18, 2009
#
#	PlayState.rb contains the state for game play

class Play < GameState
	
	def initialize(window)
		@window = window
		@background = Image.new(@window, 'images/Town1_2.png', true)
		@background.init
		
		@explosion = Gosu::Sample.new(@window, 'sounds/fireworks2.wav')
		@explosions = [] 
		
		@player = Player.new(@window, 'images/Player_pin.png', true)
		@player.init(@window, self)
		@player.x = 450
		@player.y = 300
		
		i = 0
		@hearts = Array.new(11) { |h|
			h = Image.new(@window, 'images/Heart' + i.to_s + '.png', true)
			i = i + 1
			h.init
			h.x = 15
			h.y = 15
			h.z = 4
			h
		}
		
		@heartAura = Image.new(@window, 'images/Aura.png', true)
		@heartAura.init
		@heartAura.x = -2
		@heartAura.y = -2
		@heartAura.scale = 2.0
		@heartAura.z = 3
		
		i = 0
		@zombies = Array.new(50) { |z|
			z = Zombie.new(@window, 'images/Zombie' + (rand(3.9)+1).to_s + '.png', true)
			z.init(i, self)
			i += 1
			z.centerX = 0.5
			z.centerY = 0.8
			z.x = 10 + rand(50)
			z.y = 220 + rand(200)
			z
		}
		
		@donuts = []
		
		@objects = @zombies | [@player]
		
		@collisionGrid = eval(File.read('Town1_collision.rb'))
		@VectorField = Array.new(@collisionGrid.size, Array.new(@collisionGrid[0].size, [rand(2)-1, rand(2)-1]))
		
		@startTime = Gosu.milliseconds
		@time = 0
	end
	
	def button_down(id)
		@window.states_push( Pause.new(@window) ) if id == Gosu::Button::KbP
	end
	
	def button_up(id)
	end
	
	def update
		@objects.sort! {|a,b|
			a.y <=> b.y
		}
		
		@donuts.delete_if { |d|
			d.health.zero?
		}
		@zombies.delete_if { |d|
			d.health.zero?
		}
		@explosions.delete_if { |exp|
			exp.health.zero?
		}
		@objects.delete_if { |d|
			d.health.zero?
		}
		
		
		@time = (Gosu.milliseconds - @startTime) / 1000
		@window.states_replace( Credits.new(@window, true, @time, @player.health, @player.inventory, @zombies.size) ) if @zombies.size.zero?
		@window.states_replace( Credits.new(@window, false,  @time, @player.health, @player.inventory, @zombies.size) ) if @player.health.zero?
		
		@objects.update(@window)
		
		@heartAura.alpha = @player.bite*8
	end
	
	def draw
		@background.quick_draw
		@objects.quick_draw
		
		@heartAura.quick_draw
		@hearts[@player.health].quick_draw 
		
		@window.text.draw_rel("Donuts: " + @player.inventory.to_s, 45, 64, 4, 0.5, 0.5)
		
		@window.text.draw_rel("X", @window.mouse_x, @window.mouse_y, 4, 0.5, 0.5)
	end
	
	def addExplosion( x, y, color)
		exp = Explosion.new( x, y, color, @window)
		@explosions << exp
		@objects << exp
		@explosion.play
	end
	
	def blocking?(x,y)
		return true if x < 0 or y < 0
		return true if x >= 640 or y >= 480
		@collisionGrid[y/10][x/10] == 1
	end
	
	def getField(x,y)
		return false if x < 0 or y < 0
		return false if x >= 640 or y >= 480
		@VectorField[y/10][x/10]
	end
	
	def setField(x,y, val)
		return false if x < 0 or y < 0
		return false if x >= 640 or y >= 480
		@VectorField[y/10][x/10] = val
	end
	
	def getTargets
		[@player] | @donuts
	end
	
	def addDonut(donut)
		@donuts << donut
		@objects << donut
	end
	
	def playerAttack(x,y)
		count = 0
		@zombies.each { |z|
			dist = Gosu::distance( x, y, z.x, z.y)
			if dist < 24 and count < 10
				z.hit( x, y)
				count += 1
			end
		}
	end

end
