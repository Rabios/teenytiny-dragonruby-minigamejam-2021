class Sprite
  attr_accessor :x, :y, :w, :h, :path, :angle, :a, :r, :g, :b, :tile_x, :tile_y, :tile_w, :tile_h, :source_x, :source_y, :source_w, :source_h, :flip_horizontally, :flip_vertically, :angle_anchor_x, :angle_anchor_y, :blendmode_enum
  
  def initialize(x, y, w, h, path, angle = 0, r = 255, g = 255, b = 255, a = 255)
    @x = x
    @y = y
    @w = w
    @h = h
    @path = path
    @angle = angle
    @r = r
    @g = g
    @b = b
    @a = a
  end

  def primitive_marker
    :sprite
  end
end

class SuperSprite
  attr_accessor :x, :y, :w, :h, :path, :angle, :a, :r, :g, :b, :tile_x, :tile_y, :tile_w, :tile_h, :source_x, :source_y, :source_w, :source_h, :flip_horizontally, :flip_vertically, :angle_anchor_x, :angle_anchor_y, :blendmode_enum
  
  def initialize(src_x, src_y, src_w, src_h, x, y, w, h, path, angle = 0, r = 255, g = 255, b = 255, a = 255)
    @source_x = src_x
    @source_y = src_y
    @source_w = src_w
    @source_h = src_h
    @x = x
    @y = y
    @w = w
    @h = h
    @path = path
    @angle = angle
    @r = r
    @g = g
    @b = b
    @a = a
  end

  def primitive_marker
    :sprite
  end
end

class Solid
  attr_accessor :x, :y, :w, :h, :r, :g, :b, :a, :blendmode_enum
  
  def initialize(x, y, w, h, r = 0, g = 0, b = 0, a = 255)
    @x = x
    @y = y
    @w = w
    @h = h
    @r = r
    @g = g
    @b = b
    @a = a
  end

  def primitive_marker
    :solid
  end
end

class Border
  attr_accessor :x, :y, :w, :h, :r, :g, :b, :a, :blendmode_enum
  
  def initialize(x, y, w, h, r = 0, g = 0, b = 0, a = 255)
    @x = x
    @y = y
    @w = w
    @h = h
    @r = r
    @g = g
    @b = b
    @a = a
  end

  def primitive_marker
    :border
  end
end

class Line
  attr_accessor :x, :y, :x2, :y2, :r, :g, :b, :a, :blendmode_enum
  
  def initialize(x, y, x2, y2, r = 0, g = 0, b = 0, a = 255)
    @x = x
    @y = y
    @x2 = x2
    @y2 = y2
    @r = r
    @g = g
    @b = b
    @a = a
  end

  def primitive_marker
    :line
  end
end

class Label
  attr_accessor :x, :y, :text, :font, :size_enum, :r, :g, :b, :a, :alignment_enum, :vertical_alignment_enum, :blendmode_enum
  
  def initialize(x, y, text, size_enum = 0, font = nil, r = 0, g = 0, b = 0, a = 255)
    @x = x
    @y = y
    @text = text
    @size_enum = size_enum
    @font = font
    @r = r
    @g = g
    @b = b
    @a = a
  end

  def primitive_marker
    :label
  end
end

def draw_img(rec, img, angle = 0, r = 255, g = 255, b = 255, a = 255)
  $gtk.args.outputs.primitives << Sprite.new(rec.x, rec.y, rec.w, rec.h, img, angle, r, g, b, a)
end

def draw_border(rec, r = 255, g = 255, b = 255, a = 255)
  $gtk.args.outputs.primitives << Border.new(rec.x, rec.y, rec.w, rec.h, r, g, b, a)
end

def is_mobile
  return ($gtk.platform == "iOS" || $gtk.platform == "Android")
end

def touch_down(args)
  return (args.state.metadata.touched == 1)
end

def touch_press(args)
  return (args.state.metadata.touched == 1 && (args.state.metadata.touched != args.state.metadata.touched_previously))
end

def tap(args)
  return (args.inputs.mouse.click && args.inputs.mouse.button_left) || touch_press(args)
end

def pointer_rect args
  r = { w: 1, h: 1 }

  if args.state.metadata.touched == 1
    if !(args.inputs.finger_one.nil? || args.inputs.finger_two.nil?)
      return ({ x: (args.inputs.finger_one || args.inputs.finger_two).x, y: (args.inputs.finger_one || args.inputs.finger_two).y }).merge(r)
    end
  else
    return ({ x: args.inputs.mouse.x, y: args.inputs.mouse.y }).merge(r)
  end
end

def play_select_sound args
  args.audio[:select] ||= {
    input: "audio/select.ogg",
    x: 0.0,
    y: 0.0,
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    paused: false,
    looping: false,
  }
end

def play_lose_sound args
  args.audio[:lose] ||= {
    input: "audio/lose.ogg",
    x: 0.0,
    y: 0.0,
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    paused: false,
    looping: false,
  }
end

def save_game args
  args.state.as_hash[:__thrash_count__].clear if args.state.as_hash[:__thrash_count__]
  $gtk.serialize_state("data.txt", args.state)
end

def load_game args
  if args.state.game_loaded == 0
    data = $gtk.deserialize_state("data.txt")
  
    if data
      $gtk.args.state = data
    end
    
    args.state.game_loaded          = 1
    args.state.scene                = :splashscreen
    args.state.main_menu_counters   = (4).map { 0 }
    args.state.game_counters        = (4).map { 0 }
    args.state.ext_counters         = (2).map { 0 }
    args.state.obstacles            = (4).map { (7).map { 0 } }
    args.state.lose                 = 0
    args.state.score                = 0
    args.state.fade                 = 255
    args.state.next                 = 0
  end
end

def tick args
  setup args
  load_game args
  
  args.outputs.background_color = [ 0, 0, 0, 255 ]
  
  if is_mobile
    args.state.metadata.touched_previously = args.state.metadata.touched
    args.state.metadata.touched = !args.inputs.finger_one.nil? ? 1 : 0
  end
  
  if args.state.scene == :splashscreen
    splashscreen args
  elsif args.state.scene == :main_menu
    main_menu args
  elsif args.state.scene == :game
    game args
  elsif args.state.scene == :game_over
    game_over args
  end
end

def setup args
  args.state.scene              ||= :splashscreen
  args.state.main_menu_counters ||= (4).map { 0 }
  args.state.game_counters      ||= (4).map { 0 }
  args.state.ext_counters       ||= (2).map { 0 }
  args.state.obstacles          ||= (4).map { (7).map { 0 } }
  args.state.board              ||= { x: 400, y: 100, w: 7 * 68, h: 7 * 68 }
  args.state.lose               ||= 0
  args.state.score              ||= 0
  args.state.highscore          ||= 0
  args.state.player_x           ||= args.state.board.x + (args.state.board.w - 48) / 2
  args.state.player_y           ||= args.state.board.y + (args.state.board.h - 48) / 2
  args.state.fade               ||= 255
  args.state.next               ||= 0
  args.state.touched            ||= 0
  args.state.touched_previously ||= 0
  args.state.game_loaded        ||= 0
end

def splashscreen args
  args.outputs.primitives << Sprite.new((args.grid.w - 256) / 6, 1000 - args.state.ext_counters[0], 256, 256, "metadata/icon.png", args.state.ext_counters[0] + 10 < 750 ? args.state.ext_counters[0] : 0)
  
  if args.inputs.keyboard.key_down.escape
    if $gtk.platform != "Emscripten"
      $gtk.request_quit
    end
  end
  
  if args.state.ext_counters[0] + 10 < 750
    args.state.ext_counters[0] += 10
  else
    if args.state.ext_counters[1] + 1 < 2
      args.audio[:start] = {
        input: "audio/341695__projectsu012__coins-1.ogg",
        x: 0.0,
        y: 0.0,
        z: 0.0,
        gain: 1.0,
        pitch: 1.0,
        paused: false,
        looping: false,
      }
        
      args.state.ext_counters[1] += 1
    else
      if args.state.tick_count % 60 == 0
        args.state.scene = :main_menu
        args.state.ext_counters = (2).map { 0 }
      end
    end
  end
  
  args.outputs.primitives << Label.new(
    1280 - args.state.ext_counters[0],
    (args.grid.h + 100) / 2,
    "DragonRuby",
    20,
    "fonts/ARCADE_N.ttf",
    255,
    0,
    0,
    args.state.fade)
end

def main_menu args
  if args.state.main_menu_counters[3] < 920
    args.state.main_menu_counters[3] += 10
  else
    if args.inputs.keyboard.key_down.space || args.inputs.keyboard.key_down.enter
      play_select_sound args
      args.state.next = 1
    end
  end
  
  if args.state.next == 1
    if args.state.fade > 0
      args.state.fade -= 10
    else
      args.state.scene = :game
      args.state.fade = 255
      args.state.next = 0
      
      args.state.main_menu_counters = (4).map { 0 }
      args.state.game_counters      = (4).map { 0 }
      args.state.ext_counters       = (2).map { 0 }
      args.state.timetag_counters   = (4).map { (7).map { 0 } }
      args.state.obstacles          = (4).map { (7).map { 0 } }
      args.state.score              = 0
      args.state.lose               = 0
      args.state.player_x           = args.state.board.x + (args.state.board.w - 48) / 2
      args.state.player_y           = args.state.board.y + (args.state.board.h - 48) / 2
    end
  end
  
  args.outputs.primitives << Label.new(
    args.state.main_menu_counters[3] - 630,
    600,
    "SPIKEFALL",
    28,
    "fonts/ARCADE_N.ttf",
    255,
    0,
    0,
    args.state.fade)
  
  3.times do |i|
    if args.state.main_menu_counters[i] < 610
      args.state.main_menu_counters[i] += (i + 2) * 3
    end
    
    args.outputs.primitives << Sprite.new(
      820 + (i * 52),
      args.state.main_menu_counters[i],
      48,
      48,
      "img/spike.png",
      0,
      255,
      0,
      0,
      args.state.fade)
  end
  
  if args.state.main_menu_counters[3] >= 920
    sp_rec = {
      x: 16,
      y: 16,
      w: 64,
      h: 64
    }
    
    dr_rec = {
      x: 1194,
      y: 16,
      w: 72,
      h: 72
    }
    
    args.outputs.primitives << Label.new(
      280,
      100,
      "PRESS [ENTER/SPACE] TO START!",
      2,
      "fonts/ARCADE_R.ttf",
      255,
      0,
      0,
      args.state.fade)
  
    draw_img(sp_rec, "img/rabios.png")
    draw_img(dr_rec, "metadata/icon.png")
    
    if tap(args)
      p = pointer_rect(args)
      
      if p.intersect_rect?(sp_rec)
        play_select_sound args
        $gtk.openurl("https://github.com/Rabios")
      end
      
      if p.intersect_rect?(dr_rec)
        play_select_sound args
        $gtk.openurl("https://dragonruby.org/toolkit/game")
      end
    end
  end
end

def game args
  if args.state.lose == 1
    if args.state.fade > 0
      args.state.fade -= 3
    else
      args.state.scene = :game_over
      args.state.fade = 255
      args.state.next = 0
      args.state.main_menu_counters = (4).map { 0 }
      args.state.game_counters      = (4).map { 0 }
      args.state.ext_counters       = (2).map { 0 }
      args.state.timetag_counters   = (4).map { (7).map { 0 } }
      args.state.obstacles          = (4).map { (7).map { 0 } }
      args.state.lose               = 0
      args.state.player_x           = args.state.board.x + (args.state.board.w - 48) / 2
      args.state.player_y           = args.state.board.y + (args.state.board.h - 48) / 2
      
      if args.state.score > args.state.highscore
        args.state.highscore = args.state.score
      end
      
      save_game args
    end
  end
  
  handle_gameplay args
  
  args.outputs.primitives << Label.new(
    0,
    10.from_top,
    args.state.highscore,
    24,
    "fonts/ARCADE_N.ttf",
    255,
    0,
    0,
    args.state.fade)
  
  args.outputs.primitives << Label.new(
    10,
    80.from_top,
    args.state.score,
    10,
    "fonts/ARCADE_N.ttf",
    255,
    0,
    0,
    args.state.fade)
  
  args.outputs.primitives << Border.new(
    400,
    100,
    7 * 68,
    7 * 68,
    255,
    0,
    0,
    args.state.fade)
  
  if args.state.lose == 0
    args.outputs.primitives << Border.new(
      args.state.player_x,
      args.state.player_y,
      32,
      32,
      39,
      193,
      221,
      args.state.fade)
    
    if args.state.tick_count % 60 == 0
      args.state.score += 1
    end
  end
end

def game_over args
  if args.state.next > 0
    if args.state.fade > 0
      args.state.fade -= 3
    else
      if args.state.next == 1
        args.state.scene = :game
        args.state.main_menu_counters = (4).map { 0 }
        args.state.game_counters      = (4).map { 0 }
        args.state.ext_counters       = (2).map { 0 }
        args.state.timetag_counters   = (4).map { (7).map { 0 } }
        args.state.obstacles          = (4).map { (7).map { 0 } }
        args.state.score              = 0
        args.state.lose               = 0
        args.state.player_x           = args.state.board.x + (args.state.board.w - 48) / 2
        args.state.player_y           = args.state.board.y + (args.state.board.h - 48) / 2
      
        args.state.scene = :game
      elsif args.state.next == 2
        args.state.scene = :main_menu
      end
      
      args.state.next = 0
      args.state.fade = 255
    end
  end
  
  if args.inputs.keyboard.key_down.space || args.inputs.keyboard.key_down.enter
    play_select_sound args
    args.state.next = 1
  end
  
  if args.inputs.keyboard.key_down.escape
    play_select_sound args
    args.state.next = 2
  end

  args.outputs.primitives << Label.new(
    300,
    580,
    "GAME OVER!",
    25,
    "fonts/ARCADE_N.ttf",
    255,
    0,
    0,
    args.state.fade)
  
  args.outputs.primitives << Label.new(
    380,
    370,
    "SCORE:     #{args.state.score.to_s.rjust(4, "0")}",
    6,
    "fonts/ARCADE_I.ttf",
    39,
    193,
    221,
    args.state.fade)
  
  args.outputs.primitives << Label.new(
    380,
    260,
    "HIGHSCORE: #{args.state.highscore.to_s.rjust(4, "0")}",
    6,
    "fonts/ARCADE_I.ttf",
    39,
    193,
    221,
    args.state.fade)
  
  args.outputs.primitives << Label.new(
    20,
    30,
    "[ENTER/SPACE]: RESTART",
    -2,
    "fonts/ARCADE_R.ttf",
    39,
    193,
    221,
    args.state.fade)
  
  args.outputs.primitives << Label.new(
    920,
    30,
    "[ESCAPE]: MAIN MENU",
    -2,
    "fonts/ARCADE_R.ttf",
    39,
    193,
    221,
    args.state.fade)
end

def handle_gameplay args
  ###### PLAYER MOVEMENT ######
  if args.inputs.keyboard.left || args.inputs.keyboard.a
    if args.state.player_x - 8 > args.state.board.x
      args.state.player_x -= 8
    end
  end
  
  if args.inputs.keyboard.right || args.inputs.keyboard.d
    if args.state.player_x + 8 < (args.state.board.x + args.state.board.w) - 32
      args.state.player_x += 8
    end
  end
  
  if args.inputs.keyboard.up || args.inputs.keyboard.w
    if args.state.player_y + 8 < (args.state.board.y + args.state.board.h) - 32
      args.state.player_y += 8
    end
  end
  
  if args.inputs.keyboard.down || args.inputs.keyboard.s
    if args.state.player_y - 8 > args.state.board.y
      args.state.player_y -= 8
    end
  end
  
  if args.state.tick_count % 90 == 0
    args.state.obstacles.length.times do |i|
      args.state.obstacles[i].length.times do |j|
        if args.state.obstacles[i][j] == 0
          if rand(10) % 2 == 0
            args.state.obstacles[i][j] = rand(2)
          end
        end
      end
    end
  end
  
  ###### SPIKES LOGIC ######
  4.times do |i|
    args.state.obstacles[i].length.times do |j|
      args.state.timetag_counters[i].length.times do |k|
        if args.state.obstacles[i][j] == 1
          args.state.timetag_counters[i][j] += 0.35
          
          if args.state.timetag_counters[i][j] > 660
            args.state.obstacles[i][j] = 0
            args.state.timetag_counters[i][j] = 0
          end
        end
      end
    end
  end
  
  p_rec = { x: args.state.player_x, y: args.state.player_y, w: 32, h: 32 }
  cases = [ 0, 0, 0, 0 ]
  
  args.state.obstacles[0].length.times do |i|
    if args.state.obstacles[0][i] == 1
      r0 = {
        x: args.state.board.x + (i * 70) + 2,
        y: ((args.state.board.y + args.state.board.h + 64) - args.state.timetag_counters[0][i]),
        w: 48,
        h: 48,
        path: "img/spike.png",
        angle: 180,
        r: 255,
        g: 0,
        b: 0,
        a: args.state.fade
      }
    
      args.outputs.primitives << Sprite.new(r0.x, r0.y, r0.w, r0.h, r0.path, r0.angle, r0.r, r0.g, r0.b, r0.a)
    
      if p_rec.intersect_rect?(r0)
        cases[0] = 1
      end
    end
  end
  
  args.state.obstacles[1].length.times do |i|
    if args.state.obstacles[1][i] == 1
      r1 = {
        x: args.state.board.x - 148 + (args.state.timetag_counters[1][i]),
        y: ((args.state.board.y + (args.state.board.h - 58)) - (i * 68)),
        w: 48,
        h: 48,
        path: "img/spike.png",
        angle: 270,
        r: 255,
        g: 0,
        b: 0,
        a: args.state.fade
      }
      
      args.outputs.primitives << Sprite.new(r1.x, r1.y, r1.w, r1.h, r1.path, r1.angle, r1.r, r1.g, r1.b, r1.a)
    
      if p_rec.intersect_rect?(r1)
        cases[1] = 1
      end
    end
  end
  
  args.state.obstacles[2].length.times do |i|
    if args.state.obstacles[2][i] == 1
      r2 = {
        x: args.state.board.x + 550 - (args.state.timetag_counters[2][i]),
        y: ((args.state.board.y + (args.state.board.h - 58)) - (i * 68)),
        w: 48,
        h: 48,
        path: "img/spike.png",
        angle: 90,
        r: 255,
        g: 0,
        b: 0,
        a: args.state.fade
      }
      
      args.outputs.primitives << Sprite.new(r2.x, r2.y, r2.w, r2.h, r2.path, r2.angle, r2.r, r2.g, r2.b, r2.a)
      
      if p_rec.intersect_rect?(r2)
        cases[2] = 1
      end
    end
  end
  
  args.state.obstacles[3].length.times do |i|
    if args.state.obstacles[3][i] == 1
      r3 = {
        x: args.state.board.x + (i * 70) + 2,
        y: (args.state.board.y - 148 + args.state.timetag_counters[3][i]),
        w: 48,
        h: 48,
        path: "img/spike.png",
        angle: 0,
        r: 255,
        g: 0,
        b: 0,
        a: args.state.fade
      }
      
      args.outputs.primitives << Sprite.new(r3.x, r3.y, r3.w, r3.h, r3.path, r3.angle, r3.r, r3.g, r3.b, r3.a)
      
      if p_rec.intersect_rect?(r3)
        cases[3] = 1
      end
    end
  end
  
  args.state.obstacles[3].length.times do |i|
    if args.state.obstacles[3][i] == 1
      if p_rec.intersect_rect?({ x: args.state.board.x + (i * 70) + 2, y: (args.state.board.y - 148 + args.state.timetag_counters[3][i]), w: 48, h: 48 })
        cases[3] = 1
      end
    end
  end
  
  if cases.include?(1)
    play_lose_sound args
    args.state.lose = 1
  end
end
