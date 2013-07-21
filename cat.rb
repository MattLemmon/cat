#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu
include Chingu

#
# Window Class "World"
#
class World < Chingu::Window
  def initialize
    super    
    self.input = { :escape => :exit }
    Cat.create(:x => $window.width/3*2, :y => $window.height/5*3)
    self.caption = "           gato                       Gato                         GATO                          Gato                             gato"
  # self.factor = 2
  # retrofy
  end
end

#
#  Player Class "Cat"
#
class Cat < Chingu::GameObject
  traits :timer
 
  def initialize(window)
    super
    
    self.input = { :"2" => :second_player,
                   :holding_space => :meow,
                   :holding_left => :left,
                   :holding_right => :right,
                   :holding_up => :up,
                   :holding_down => :down  }
    
    # Load the full animation from tile-file media/plyr1.png
    @animation = Chingu::Animation.new(:file => "media/plyr1.png", :center_x => 500, :center_y => 500, :delay => 70)
    @animation.frame_names = { :stand1 => 0..0, :stand2 => 3..3, :walkleft => 1..2, :walkright => 4..5,
                               :blink1 => 6..6, :blink2 => 7..7 }

    # Start out by animation contained in @animation[:stand1]
    @frame_name = :stand1
    
    @last_x, @last_y = @x, @y
    @dir = -1
    @cooling_down = false
    @cooling_down2 = false
    @second_pl = false
  end

  def meow
    return if @cooling_down
    @cooling_down = true
    after(250) { @cooling_down = false }
    if rand(3) == 1
      Sound["meow1.wav"].play(0.8)
    else
      if rand(2) == 1
        Sound["meow2.wav"].play(0.8)
      else
        Sound["meow3.wav"].play(0.6)
      end
    end
  end

  def second_player
    if @second_pl == false
      Plyr2.create(:x => $window.width/3, :y => $window.height/5*3)
      @second_pl = true
    else
      Plyr2.destroy_all
      @second_pl = false
    end
  end

  def left
    @x -= 8
    @frame_name = :walkleft
    @dir = -1
  end

  def right
    @x += 8
    @frame_name = :walkright
    @dir = 1
  end
  
  def up
    @y -= 8
    if @dir == -1
      @frame_name = :walkleft
    else
      @frame_name = :walkright
    end
  end

  def down
    @y += 8
    if @dir == -1
      @frame_name = :walkleft
    else
      @frame_name = :walkright
    end
  end

  def draw
    #Image.draw(x,y,zorder) For some reason this is where the background image goes
    Image["blank.png"].draw(0, 0, 0)
    super
  end

  def update
    # Move the animation forward by fetching the next frame and putting it into @image
    # @image is drawn by default by GameObject#draw
    @image = @animation[@frame_name].next
    
    # If Cat stands still, use the blink animation
    if @x == @last_x && @y == @last_y
      if @dir == 1
        @frame_name = (milliseconds / 140 % 15 == 0) ? :blink2 : :stand2
      else
        @frame_name = (milliseconds / 140 % 15 == 0) ? :blink1 : :stand1
      end
    end

    # wrap around the screen
    if @x < -65
      @x = 865
    end
    if @y < -60
      @y = 650
    end
    if @x > 865
      @x = -65
    end
    if @y > 650
      @y = -60
    end

    # save current coordinates for possible use next time
    @last_x, @last_y = @x, @y
  end
end

class Plyr2 < Chingu::GameObject
  traits :timer
 
  def initialize(window)
    super
    self.input = { :holding_a => :left,
                   :holding_d => :right,
                   :holding_w => :up,
                   :holding_s => :down  }
    
    @animation = Chingu::Animation.new(:file => "media/plyr2.png", :center_x => 500, :center_y => 500, :delay => 70)
    @animation.frame_names = { :stand1 => 0..0, :stand2 => 3..3, :walkleft => 1..2, :walkright => 4..5,
                               :blink1 => 6..6, :blink2 => 7..7 }
    @frame_name = :stand1    
    @last_x, @last_y = @x, @y
    @dir = 1
    update
  end

  def left
    @x -= 8
    @frame_name = :walkleft
    @dir = -1
  end

  def right
    @x += 8
    @frame_name = :walkright
    @dir = 1
  end
  
  def up
    @y -= 8
    if @dir == -1
      @frame_name = :walkleft
    else
      @frame_name = :walkright
    end
  end

  def down
    @y += 8
    if @dir == -1
      @frame_name = :walkleft
    else
      @frame_name = :walkright
    end
  end


  def update
    
    @image = @animation[@frame_name].next

    # blinks when standing still
    if @x == @last_x && @y == @last_y
      if @dir == 1
        @frame_name = (milliseconds / 220 % 16 == 0) ? :blink2 : :stand2
      else
        @frame_name = (milliseconds / 220 % 16 == 0) ? :blink1 : :stand1
      end
    end

    # wrap around the screen
    if @x < -65
      @x = 865
    end
    if @y < -60
      @y = 650
    end
    if @x > 865
      @x = -65
    end
    if @y > 650
      @y = -60
    end

    @last_x, @last_y = @x, @y    # save current coordinates
  end
end

World.new.show     # launch Window
