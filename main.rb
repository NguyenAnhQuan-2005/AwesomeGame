require 'gosu'

SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 720

module ZOrder
  BACKGROUND, ENEMY, HIT_EFFECT, PLAYER, UI, BUTTON, TEXT = *0..6
end

# background looks like star (simulate universe)

class Background
  STAR_COUNT = 100

  def initialize
    @stars = Array.new(STAR_COUNT) { random_star }
  end

  def update
    # animate if I like but do it later
  end

  def draw
    @stars.each do |star|
      Gosu.draw_rect(star[:x], star[:y], 2, 2, Gosu::Color::WHITE, ZOrder::BACKGROUND)
    end
  end

  def random_star
    { x: rand(SCREEN_WIDTH), y: rand(SCREEN_HEIGHT) }
  end
end


class Button
  attr_reader :x, :y, :width, :height, :label

  def initialize(window, label, x, y, width, height, &action) # Set up the attribute
    @window = window
    @label = label
    @x, @y, @width, @height = x, y, width, height
    @font = Gosu::Font.new(28)
    @action = action
  end

  def draw
    
    color = hovered? ? Gosu::Color::AQUA : Gosu::Color::GRAY

    # Draw button background
    Gosu.draw_rect(@x, @y, @width, @height, color, ZOrder::BUTTON)
    
    #border button
    Gosu.draw_rect(@x, @y, @width, 2, Gosu::Color::WHITE, ZOrder::BUTTON)
    Gosu.draw_rect(@x, @y + @height - 2, @width, 2, Gosu::Color::WHITE, ZOrder::BUTTON)
    Gosu.draw_rect(@x, @y, 2, @height, Gosu::Color::WHITE, ZOrder::BUTTON)
    Gosu.draw_rect(@x + @width - 2, @y, 2, @height, Gosu::Color::WHITE, ZOrder::BUTTON)

    # Draw centered text
    text_width = @font.text_width(@label)
    text_x = @x + (@width - text_width) / 2
    text_y = @y + (@height - 28) / 2
    @font.draw_text(@label, text_x, text_y, ZOrder::TEXT, 1.0, 1.0, Gosu::Color::BLACK)

  end

  def hovered?
    mx = @window.mouse_x
    my = @window.mouse_y
    mx >= @x && mx <= @x + @width && my >= @y && my <= @y + @height
  end

  def click(mouse_x, mouse_y)
    if mouse_x >= @x && mouse_x <= @x + @width &&
       mouse_y >= @y && mouse_y <= @y + @height
      @action.call
    end
  end
end


class IntroScreen
  def initialize(window)
    @window = window
    @title_font = Gosu::Font.new(60)
    @buttons = []
    @background = Background.new
    

    # Buttons
    @buttons << Button.new(window, "Play", SCREEN_WIDTH/2 - 100, 400, 200, 50) do
      window.start_game
    end

    @buttons << Button.new(window, "How to Play", SCREEN_WIDTH/2 - 100, 480, 200, 50) do
      window.show_tutorial
    end
  end

  def draw
    @background.draw
    # Draw stars

    # Draw title
    title = "The Adventure of Pepe"
    text_width = @title_font.text_width(title)
    @title_font.draw_text(title, (SCREEN_WIDTH - text_width) / 2, SCREEN_HEIGHT / 4, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)

    # Draw buttons
    @buttons.each(&:draw)
  end

  def button_down(id)
    if id == Gosu::MsLeft
      @buttons.each do |button|
        button.click(@window.mouse_x, @window.mouse_y)
      end
    end
  end
end

class TutorialScreen
  def initialize(window)
    @window = window
    @title_font = Gosu::Font.new(48)
    @text_font = Gosu::Font.new(28)
    @background = Background.new
    @button = Button.new(window, "Done", SCREEN_WIDTH / 2 - 100, 500, 200, 50) do
      @window.show_intro
    end
  end

  def draw

    @background.draw
    # Title
    title = "Tutorial"
    title_width = @title_font.text_width(title)
    @title_font.draw_text(title, (SCREEN_WIDTH - title_width) / 2, 100, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)

    # Main tutorial
    instruction = "Press UP / DOWN / LEFT / RIGHT to move\nPress SPACE to hit enemies\nHit the rabbit, dog to gain score to 15\nHit the bat to lose score and lose the whole game in 0\n Failure to hitting rabbit and dog lose score \n Crashing to either enemies wil lose score \n Good luck :) "
    lines = instruction.split("\n")
    i = 0
    while i < lines.length
      line = lines[i]
      line_width = @text_font.text_width(line)
      @text_font.draw_text(line, (SCREEN_WIDTH - line_width) / 2, 220 + i * 40, ZOrder::TEXT, 1.0, 1.0, Gosu::Color::WHITE)
      i += 1
    end
    

    # Button
    @button.draw
  end

  def button_down(id)
    if id == Gosu::MsLeft
      @button.click(@window.mouse_x, @window.mouse_y)
    end
  end
end


class LosingScreen
  def initialize(window)
    @window = window
    @background = Background.new
    @font = Gosu::Font.new(80)

    #display done button
    @done_button = Button.new(@window, "Done", SCREEN_WIDTH / 2 - 100, SCREEN_HEIGHT / 2 + 60, 200, 50) do
      @window.show_intro
    end
  end

  def draw
    @background.draw
    @font.draw_text("GAME!!!!!!!", SCREEN_WIDTH / 2 - 150 , SCREEN_HEIGHT / 2 - 60, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    @done_button.draw
  end

  def button_down(id)
    if id == Gosu::MsLeft
      @done_button.click(@window.mouse_x, @window.mouse_y)
      return true
    end
    false
  end
end


class WinningScreen
  def initialize(window)
    @window = window
    @background = Background.new
    @font = Gosu::Font.new(80)

    #display done button
    @done_button = Button.new(@window, "Done", SCREEN_WIDTH / 2 - 100, SCREEN_HEIGHT / 2 + 60, 200, 50) do
      @window.show_intro
    end
  end

  def draw
    @background.draw
    @font.draw_text("PePe make it", SCREEN_WIDTH / 2 - 200, SCREEN_HEIGHT / 2 - 60, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    @done_button.draw
  end

  def button_down(id)
    if id == Gosu::MsLeft
      @done_button.click(@window.mouse_x, @window.mouse_y)
    end
  end
end



class Player
  attr_reader :x, :y, :lane

  def initialize
    @image = Gosu::Image.new("media/player.png")
    @width = SCREEN_WIDTH / 15
    @height = SCREEN_HEIGHT / 7
    @x = 50
    @lane = 0
    update_y
  end

  def draw
    @image.draw(@x, @y, ZOrder::PLAYER, @width.to_f / @image.width, @height.to_f / @image.height)
  end

  def move_up
    @lane -= 1 if @lane > 0
    update_y
  end

  def move_down
    @lane += 1 if @lane < 5
    update_y
  end

  def move_left
    @x -= 20 if @x > 0
  end

  def move_right
    @x += 20 if @x + @width < SCREEN_WIDTH
  end

  def update_y
    section_height = SCREEN_HEIGHT / 6
    @y = (section_height * @lane) + (section_height - @height) / 2
  end
end



class Enemy
  attr_reader :x, :y, :type

  SPEED = 3
  

  def initialize(images)
    @images = images
    @type, @image = @images.to_a.sample
    @x = SCREEN_WIDTH + 100
    @lane = rand(0..5)

    section_height = SCREEN_HEIGHT / 6
    target_height = section_height * 0.9  # 90% of the lane for padding
    scale = target_height / @image.height
    @scale_x = scale
    @scale_y = scale
    @width = @image.width * @scale_x
    @height = @image.height * @scale_y

    @y = @lane * section_height + (section_height - @height) / 2
  end

  def update
    @x -= SPEED
  end

  def draw
    @image.draw(@x, @y, ZOrder::ENEMY, @scale_x, @scale_y)
  end

  def off_screen?
    @x + @width < 0
  end

  def collides_with?(player)
    player_x, player_y = player.x, player.y
    dx = (@x - player_x).abs
    dy = (@y - player_y).abs
    dx < @width * 0.7 && dy < @height * 0.7
  end
end





class GameWindow < Gosu::Window
  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT)
    self.caption = "The Adventure of Pepe"
    @losing_screen = LosingScreen.new(self)
    @state = :intro
    @intro_screen = IntroScreen.new(self)
    @tutorial_screen = TutorialScreen.new(self)
    @gameplay_background = Background.new 
    @player = Player.new
    @move_lock = false
    @move_lock_timer = 0
    @hit_effect_img = Gosu::Image.new("media/hit.png")
    @show_hit_effect = false
    @hit_effect_timer = 0
    @hit_sound = Gosu::Sample.new("media/hit.mp3")
    @hit_sound_s = Gosu::Sample.new("media/hit_s.mp3")
    @nope_sound = Gosu::Sample.new("media/nope.mp3")
    @crash_sound = Gosu::Sample.new("media/crash.mp3")
    @score = 0
    @score_font = Gosu::Font.new(32) 
    @winning_screen = nil

    @enemy_images = {
      rabbit: Gosu::Image.new("media/rabbit.png"),
      bat:    Gosu::Image.new("media/bat.png"),
      dog:    Gosu::Image.new("media/dog.png")
    } 
    @enemies = []
    @enemy_spawn_timer = 0
  end

  def draw_score
    text = "Score: #{@score}"
    @score_font.draw_text(text, 20, 20, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
  end

  def draw_gameplay_background
    @gameplay_background.draw    
    # Draw 5 horizontal lane lines to make 6 lanes
    lane_height = SCREEN_HEIGHT / 6
    1.upto(5) do |i|
      y = i * lane_height
      draw_line(0, y, Gosu::Color::WHITE, SCREEN_WIDTH, y, Gosu::Color::WHITE, ZOrder::UI)
    end

  end


  def draw_hit_effect
    return unless @show_hit_effect

    if Gosu.milliseconds - @hit_effect_timer > 200
      @show_hit_effect = false
    else
      scale = 0.2
      effect_x = @player.x + 60  # adjust based on Pepe image width
      effect_y = @player.y + 10  # adjust for vertical alignment
      @hit_effect_img.draw(effect_x, effect_y, ZOrder::HIT_EFFECT, scale, scale)
    end
  end

  def show_intro
    @state = :intro
  end

  def show_tutorial
    @state = :tutorial
  end

  def reset_game_state
    @player = Player.new
    @score = 0
    @enemies = []
    @enemy_spawn_timer = 0
    @show_hit_effect = false
    @hit_effect_timer = 0
  end

  
  def start_game
    puts "Starting game..."
    reset_game_state
    @state = :playing
    # use for notification in terminal 
  end
  
  def draw
    case @state
    when :intro
      @intro_screen.draw
    when :tutorial
      @tutorial_screen.draw
    when :playing
      draw_score
      draw_gameplay_background
      @player.draw  
      @enemies.each(&:draw)
      draw_hit_effect
    when :game_over
      @losing_screen.draw
    when :game_won
      @winning_screen.draw
    end
  end


  def update
    return unless @state == :playing

    handle_player_movement
    handle_hit if Gosu.button_down?(Gosu::KB_SPACE) && !@show_hit_effect
    spawn_enemies_if_needed
    update_enemies
    check_collisions_and_offscreen

      # Game over condition
      if @score < 0 && @state != :game_over
        Gosu::Sample.new("media/game.mp3").play
        @losing_screen = LosingScreen.new(self)
        @state = :game_over
      end
      if @score >= 15 && @state != :game_won
        Gosu::Sample.new("media/win.mp3").play
        @winning_screen = WinningScreen.new(self)
        @state = :game_won
      end

    end

    def handle_player_movement
      if Gosu.button_down?(Gosu::KB_UP) && !@move_lock
        @player.move_up
        lock_movement
      elsif Gosu.button_down?(Gosu::KB_DOWN) && !@move_lock
        @player.move_down
        lock_movement
      elsif Gosu.button_down?(Gosu::KB_LEFT)
        @player.move_left
      elsif Gosu.button_down?(Gosu::KB_RIGHT)
        @player.move_right
      end

      @move_lock = false if @move_lock && Gosu.milliseconds - @move_lock_timer > 150
    end

    def lock_movement
      @move_lock = true
      @move_lock_timer = Gosu.milliseconds
    end

    def handle_hit
      @show_hit_effect = true
      @hit_effect_timer = Gosu.milliseconds
      @hit_sound.play

      hit_range_x = @player.x + 50..@player.x + 150
      hit_range_y = @player.y - 20..@player.y + 20

      #scoring system
      @enemies.reject! do |enemy|
        if hit_range_x.include?(enemy.x) && hit_range_y.include?(enemy.y)
          case enemy.type
          when :rabbit, :dog
            @score += 1
            @hit_sound_s.play
          when :bat
            @score -= 2
            @nope_sound.play
          end
          true
        else
          false
        end
      end
    end

    def spawn_enemies_if_needed
      if Gosu.milliseconds - @enemy_spawn_timer > 1500
        @enemies << Enemy.new(@enemy_images)
        @enemy_spawn_timer = Gosu.milliseconds
      end
    end

    def update_enemies
      @enemies.each(&:update)
    end

    def check_collisions_and_offscreen
      @enemies.reject! do |enemy|
      if enemy.collides_with?(@player)
        @crash_sound.play
        @score -= (enemy.type == :bat ? 2 : 1)
        true
      elsif enemy.off_screen?
        @score -= 1 if [:rabbit, :dog].include?(enemy.type)
        true
      else
        false
      end
    end
  end





  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      close
    else
      case @state
      when :intro
        @intro_screen.button_down(id)
      when :tutorial
        @tutorial_screen.button_down(id)
      when :game_over
        @losing_screen.button_down(id)
      when :game_won
        @winning_screen.button_down(id) 
      end
    end
  end



end

GameWindow.new.show
