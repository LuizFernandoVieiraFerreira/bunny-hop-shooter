pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

-- MAIN

function _init()
  change_color_pallete()
  init_global_variables()  
  init_menu()
  _update = update_menu
  _draw = draw_menu
end

function change_color_pallete()  
  _pal = { 131, 131, 131, 131, 3, 3, 139, 138, 139, 139, 138, 3, 3, 3, 139, 138 }
  if current_color_pallete == 1 then
    _pal = { 3, 3, 3, 3, 139, 139, 138, 135, 138, 138, 135, 139, 139, 139, 138, 135 }
  elseif current_color_pallete == 2 then
    _pal = { 0, 0, 0, 0, 5, 5, 6, 7, 6, 6, 7, 5, 5, 5, 6, 7 }
  elseif current_color_pallete == 3 then
    _pal = { 132, 132, 132, 132, 4, 4, 143, 15, 143, 143, 15, 4, 4, 4, 143, 15 }
  elseif current_color_pallete == 4 then 
    _pal = { 129, 129, 129, 129, 1, 1, 140, 12, 140, 140, 12, 1, 1, 1, 140, 12 }
  elseif current_color_pallete == 5 then 
    _pal = { 130, 130, 130, 130, 2, 2, 136, 14, 136, 136, 14, 2, 2, 2, 136, 14 }
  end
  for i, c in pairs(_pal) do
    pal(i-1, c, 1)
  end
  palt(0, false)
  palt(14, true)
end

function init_global_variables()
  current_color_pallete = 0
  key = {
    left = 0,
    right = 1,
    up = 2,
    down = 3,
    a = 5,
    b = 4,
  }
  sound = {
    coin = 0,
    shot = 1,
    explosion = 2,
    carrot = 3,
  }
  type = {
    player = 'player',
    bullet = 'bullet',
    enemy = 'enemy',
    enemy_bullet = 'enemy_bullet',
    coin = 'coin',
    carrot = 'carrot',
    background = 'background',
    boss = 'boss',
  }
  FIRST_PX_THIS_SCREEN = 0
  LAST_PX_THIS_SCREEN = 127
  FIRST_PX_NEXT_SCREEN = 128
  HUD_HEIGHT = 16
  TRANSITION_STARTS_PX = 128 * 8
  TRANSITION_FINISH_PX = 128 * 14
end

-- MENU

function init_menu()
  menu = {
    logo = {
      x = 18,
      y = 16,
      w = 96,
      h = 16,
      sp = 160,
      draw = function(self)
        spr(self.sp, self.x, self.y, self.w/8, self.h/8)
      end,
    },
    press_to_start = "\142.\151をフ゜レツス",
    company = "2020 gamb",
  }
end

function update_menu()
  if btnp(key.a) then -- or btnp(key.b)
    init_intro()
    _update = update_intro
    _draw = draw_intro
    -- init_game()
    -- _update = update_game
    -- _draw = draw_game
    -- init_ending()
    -- _update = update_ending
    -- _draw = draw_ending
    -- init_game_over()
    -- _update = update_game_over
    -- _draw = draw_game_over
  end
  if btnp(key.b) then
    change_color_pallete()
    current_color_pallete = wrap(current_color_pallete, 5)
  end  
end

function draw_menu()
  cls(7)
  menu.logo:draw()
  spr(192, 18, 32, 12, 4)
  spr(83, 40, 118)
  print(menu.press_to_start, 64 - (16 * 2), 88, col)
  print(menu.company, 64 - (#menu.company * 2) + 4, 120, col)  
end

-- INTRO

function init_intro()
  cutscene = {
    scene = {},
    actors = {},
    backgrounds = {},
    step = 1,
    timer = 0,
    add_actor = function(self, s, a)      
      self.actors[s] = a
      self.actors[#cutscene.actors + 1] = a
    end,
    advance = function(self)
      if #self.scene > 0 then
        self.step += 1
      end
    end,
    wait = function(t)
      cutscene.timer += 1
      if cutscene.timer > t then
        cutscene:advance()
      end
    end,
    update = function(self)      
      if #self.scene > 0 then
        if self.step > #self.scene then
          step = 1
          timer = 0
          init_game()
          _update = update_game
          _draw = draw_game
          cutscene = {}
        else
          local f = self.scene[self.step][1]
          local p1 = self.scene[self.step][2]
          local p2 = self.scene[self.step][3]
          local p3 = self.scene[self.step][4]
          local p4 = self.scene[self.step][4]
          local p5 = self.scene[self.step][4]
          f(p1, p2, p3, p4, p5)          
        end
      end
    end,
    draw = function(self)
      foreach(self.backgrounds, function(obj) obj:draw() end)
      for k, v in ipairs(self.actors) do
        v:draw()
      end
    end,
  }
  cutscene.scene = {    
    {bunnies_kisses, 2 * 30},   
    {bunnies_kisses, 2 * 30},
    {bunnies_kisses, 2 * 30},
    {hide_heart, 1 * 30},
    {boss_goto_to_princess},
    {cutscene.wait, 0.5 * 30},
    {boss_put_cage},
    {cutscene.wait, 1 * 30},
    {boss_kidnap_princess},
    {cutscene.wait, 2 * 30},
  }
  cutscene:add_actor('player', create_player(32, 64))
  cutscene:add_actor('princess', create_princess(49, 64))
  cutscene:add_actor('heart', create_heart(42, 52))
  cutscene:add_actor('boss', create_boss(128 + 16, 64))
  cutscene:add_actor('cage', create_cage(49, 64))
  add(cutscene.backgrounds, create_sm_cloud(40, 38))
  add(cutscene.backgrounds, create_md_cloud(32, 72))
  add(cutscene.backgrounds, create_sm_cloud(96, 88))
  add(cutscene.backgrounds, create_md_cloud(80, 40))
  add(cutscene.backgrounds, create_md_cloud(64, 102))  
end

function update_intro()
  cutscene:update()
end

function draw_intro()
  cls(7)
  cutscene:draw()
end

function bunnies_kisses()
  cutscene.actors.heart.y -= 1
  if cutscene.actors.heart.y == 40 then
    cutscene.actors.heart.y = 52
    cutscene:advance()
  end
end

function hide_heart()
  cutscene.actors.heart.y = 128 + 8
  cutscene:advance()
end

function boss_goto_to_princess()
  cutscene.actors.boss.x -= 1
  if cutscene.actors.boss.x == 72 then  
    cutscene:advance()
  end
end

function boss_put_cage()
  cutscene.actors.cage.active = true
  cutscene:advance()
end

function boss_kidnap_princess()
  cutscene.actors.cage.x += 1
  cutscene.actors.boss.x += 1
  cutscene.actors.princess.x += 1
  if cutscene.actors.princess.x >= (FIRST_PX_NEXT_SCREEN + 8) then
    cutscene:advance()
  end
end

-- GAME

function init_game()  
  player = create_player(32, 64)
  transitions = {}
  backgrounds = {
    create_sm_cloud(40, 38),
    create_md_cloud(32, 72),
    create_sm_cloud(96, 88),
    create_md_cloud(80, 40),
    create_md_cloud(64, 102),
  }
  foregrounds = {}
  bullets = {}
  enemies = {}
  items = {}
  boss = nil

  coin_counter = 0
  next_bg_pattern = 1
  bg_patterns = {
    {
      create_sm_cloud(FIRST_PX_NEXT_SCREEN + 30, 28),
      create_md_cloud(FIRST_PX_NEXT_SCREEN + 22, 50),
      create_sm_cloud(FIRST_PX_NEXT_SCREEN + 26, 88),
      create_sm_cloud(FIRST_PX_NEXT_SCREEN + 64, 108),
      create_md_cloud(FIRST_PX_NEXT_SCREEN + 96, 76),
      create_md_cloud(FIRST_PX_NEXT_SCREEN + 80, 36),
    },
    {
      create_md_cloud(FIRST_PX_NEXT_SCREEN + 40, 38),
      create_sm_cloud(FIRST_PX_NEXT_SCREEN + 32, 80),
      create_md_cloud(FIRST_PX_NEXT_SCREEN + 96, 88),
      create_sm_cloud(FIRST_PX_NEXT_SCREEN + 80, 40),
    },
    {
      create_sm_cloud(FIRST_PX_NEXT_SCREEN + 40, 38),
      create_md_cloud(FIRST_PX_NEXT_SCREEN + 32, 80),
      create_sm_cloud(FIRST_PX_NEXT_SCREEN + 96, 88),
      create_md_cloud(FIRST_PX_NEXT_SCREEN + 80, 40),
      create_md_cloud(FIRST_PX_NEXT_SCREEN + 96, 112),
    },
  }

  next_obj_pattern = 1
  future_objects = {
    {
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 16, 56) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 16, 72) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 32, 56) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 32, 72) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 48, 56) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 48, 72) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 64, 56) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 64, 72) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 80, 56) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 80, 72) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 96, 56) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 96, 72) },
    },
    {
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN, 72, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 72, 56, { type = 'idle' }) }
    },
    {
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 0, 80, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 0, 98, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 32, 80, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 32, 98, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 56, 40, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 56, 58, { type = 'idle' }) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 64, 80) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 64, 98) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 88, 40, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 88, 58, { type = 'idle' }) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 120, 40) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 120, 58) }
    },
    {
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 20, 40, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 20, 72, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 20, 104, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 52, 72, { type = 'up_down', start_y = 64, range = 28, going_up = true }) },
      { tb = enemies, o = create_fox(FIRST_PX_NEXT_SCREEN + 74, 72, { type = 'up_down_shoot', start_y = 64, range = 32, going_up = true }) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 90, 72) },
      { tb = items, o = create_carrot(FIRST_PX_NEXT_SCREEN + 106, 72) }
    },
    {
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 64, 24, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 64, 120, { type = 'idle' }) },      
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 8, 72, { type = 'up_down', start_y = 72, range = 12, going_up = true }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 40, 88, { type = 'up_down', start_y = 88, range = 10, going_up = true }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 40, 56, { type = 'up_down', start_y = 56, range = 10, going_up = true }) },      
      { tb = enemies, o = create_fox(FIRST_PX_NEXT_SCREEN + 80, 88, { type = 'up_down_shoot', start_y = 88, range = 16, going_up = true }) },
      { tb = enemies, o = create_fox(FIRST_PX_NEXT_SCREEN + 80, 56, { type = 'up_down_shoot', start_y = 56, range = 16, going_up = true }) },
    },
    {
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 8, 56, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 8, 72, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 8, 88, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 24, 56, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 24, 72, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 24, 88, { type = 'idle' }) },      
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 40, 40, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 56, 40, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 72, 40, { type = 'idle' }) },      
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 40, 104, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 56, 104, { type = 'idle' }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 72, 104, { type = 'idle' }) },      
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 90, 72, { type = 'up_down', start_y = 72, range = 16, going_up = true }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 106, 72, { type = 'up_down', start_y = 72, range = 18, going_up = false }) },      
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 36, 52) }
    },
    {
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 24, 56, { type = 'up_down', start_y = 72, range = 10, going_up = true }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 56, 88, { type = 'up_down', start_y = 88, range = 12, going_up = true }) },
      { tb = enemies, o = create_bomb(FIRST_PX_NEXT_SCREEN + 88, 56, { type = 'up_down', start_y = 56, range = 16, going_up = true }) },      
      { tb = enemies, o = create_fox(FIRST_PX_NEXT_SCREEN + 24, 88, { type = 'up_down_shoot', start_y = 88, range = 10, going_up = true }) },
      { tb = enemies, o = create_fox(FIRST_PX_NEXT_SCREEN + 56, 56, { type = 'up_down_shoot', start_y = 56, range = 12, going_up = true }) },
      { tb = enemies, o = create_fox(FIRST_PX_NEXT_SCREEN + 88, 88, { type = 'up_down_shoot', start_y = 56, range = 16, going_up = true }) },      
      { tb = items, o = create_carrot(FIRST_PX_NEXT_SCREEN + 106, 72) },
    },
    {},
    {
      { tb = enemies, o = create_meteor_sm(FIRST_PX_NEXT_SCREEN + 32, 112) },
      { tb = enemies, o = create_meteor_sm(FIRST_PX_NEXT_SCREEN + 64, 80) },
      { tb = enemies, o = create_meteor_sm(FIRST_PX_NEXT_SCREEN + 112, 32) },     
      { tb = enemies, o = create_meteor(FIRST_PX_NEXT_SCREEN + 32, 32) },      
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 112, 72) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 64, 112) },
    },
    {
      { tb = enemies, o = create_meteor_sm(FIRST_PX_NEXT_SCREEN + 88, 32) },
      { tb = enemies, o = create_meteor_sm(FIRST_PX_NEXT_SCREEN + 40, 112) },
      { tb = enemies, o = create_meteor(FIRST_PX_NEXT_SCREEN + 16, 80) },
      { tb = enemies, o = create_alien(FIRST_PX_NEXT_SCREEN + 64, 96, { type = 'shoot' }) },
      { tb = enemies, o = create_alien(FIRST_PX_NEXT_SCREEN + 112, 32, { type = 'shoot' }) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 80, 48) },
    },
    {      
      { tb = enemies, o = create_meteor_sm(FIRST_PX_NEXT_SCREEN + 64, 96) },
      { tb = enemies, o = create_meteor(FIRST_PX_NEXT_SCREEN + 16, 64) },
      { tb = enemies, o = create_alien(FIRST_PX_NEXT_SCREEN + 64, 64, { type = 'shoot' }) },
      { tb = enemies, o = create_alien(FIRST_PX_NEXT_SCREEN + 64, 80, { type = 'shoot' }) },
      { tb = enemies, o = create_alien(FIRST_PX_NEXT_SCREEN + 112, 96, { type = 'shoot' }) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 32, 112) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 16, 16) },
      { tb = items, o = create_coin(FIRST_PX_NEXT_SCREEN + 96, 64) },
    },
    {
      { tb = enemies, o = create_meteor_sm(FIRST_PX_NEXT_SCREEN + 40, 112) },
      { tb = enemies, o = create_meteor_sm(FIRST_PX_NEXT_SCREEN + 40, 112) },
      { tb = enemies, o = create_alien(FIRST_PX_NEXT_SCREEN + 112, 32, { type = 'shoot' }) },
      { tb = enemies, o = create_meteor(FIRST_PX_NEXT_SCREEN + 16, 80) },
      { tb = enemies, o = create_meteor(FIRST_PX_NEXT_SCREEN + 16, 80) },
      { tb = enemies, o = create_meteor(FIRST_PX_NEXT_SCREEN + 16, 80) },
      { tb = enemies, o = create_meteor(FIRST_PX_NEXT_SCREEN + 16, 80) },
      { tb = items, o = create_carrot(FIRST_PX_NEXT_SCREEN + 106, 72) },
    },
  }
  timer = 0
  last_time = time()
  scroll_distance = 0
  time_since_boss_death = 0
end

function update_game()
  if btnp(key.b) then
    change_color_pallete()
    current_color_pallete = wrap(current_color_pallete, 5)
  end

  track_current_time()
  create_new_instances()

  player:update()

  foreach(transitions, function(obj) obj:update() end)
  foreach(backgrounds, function(obj) obj:update() end)
  foreach(bullets, function(obj) obj:update() end)
  foreach(enemies, function(obj) obj:update() end)
  foreach(items, function(obj) obj:update() end)

  if boss then
    boss:update()
  end

  foreach(foregrounds, function(obj) obj:update() end)

  check_collision()
  check_is_dead()
  delete_outside_boundries()
  update_scroll_distance()
  track_last_time()
end

function draw_game()
  clear_screen()
  foreach(transitions, function(obj) obj:draw() end)
  foreach(backgrounds, function(obj) obj:draw() end)
  player:draw()
  foreach(bullets, function(obj) obj:draw() end)
  foreach(enemies, function(obj) obj:draw() end)
  foreach(items, function(obj) obj:draw() end)

  if boss then
    boss:draw()
  end

  foreach(foregrounds, function(obj) obj:draw() end)
  draw_hud()

  print(scroll_distance, 2, 122)
end

-- ENDING

function init_ending()
  timer = 0
  last_time = time()
  ending_text = "CONGRATULATIONS!"
  ending_text_underline = "----------------"
end

function update_ending()
  track_current_time()
  track_last_time()
end

function draw_ending()
  cls(7)

  if timer < (#ending_text_underline/4) then
    local text = ""
    local text_underline = ""
    for i=1, (timer * 4) do
      text = sub(ending_text, 1, i)
      text_underline = sub(ending_text_underline, 1, i)
    end
    print_centered(text, 60)
    print_centered(text_underline, 60 + 4)
  else
    print_centered("CONGRATULATIONS!", 60)
    print_centered("----------------", 60 + 4)
  end
end

-- GAME OVER

function init_game_over()
  timer = 0
  last_time = time()
  gameover_text = "GAME OVER!"
  gameover_text_underline = "---- -----"
end

function update_game_over()
  track_current_time()
  track_last_time()
  if btnp(key.a) and timer > (#gameover_text_underline/4) then
    init_game()
    _update = update_game
    _draw = draw_game
  end
end

function draw_game_over()
  cls(7)

  if timer < (#gameover_text_underline/4) then
    local text = ""
    local text_underline = ""
    for i=1, (timer * 4) do
      text = sub(gameover_text, 1, i)
      text_underline = sub(gameover_text_underline, 1, i)
    end
    print_centered(text, 60)
    print_centered(text_underline, 60 + 4)
  else
    print_centered("GAME OVER!", 60)
    print_centered("---- -----", 60 + 4)
  end
end

-- CONSTRUCTOS

function create_player(x, y)
  return {
    x = x,
    y = y,
    w = 16,
    h = 16,
    v = 1,
    sp = 1,
    anim = 0,
    life = 3,
    state = 'flying',
    shoot_timer = 0,
    shoot_cooldown = 0.2,
    dmg_timer = 0,
    dmg_cooldown = 1,
    dmg_flick = false,
    dmg_flick_tick = true,
    type = type.player,
    update = function(self)      
      local move_left = btn(key.left) and -2 or 0
      local move_right = btn(key.right) and 1 or 0
      local move_up = btn(key.up) and -1 or 0
      local move_down = btn(key.down) and 1 or 0

      local vel_x = (move_left + move_right) * self.v
      local vel_y = (move_up + move_down) * self.v

      local old_pos_x = self.x
      local old_pos_y = self.y
      local new_pos_x = self.x + vel_x
      local new_pos_y = self.y + vel_y

      if new_pos_x < self.w/2 then
        new_pos_x = self.w/2
      end

      if new_pos_x > FIRST_PX_NEXT_SCREEN - self.w/2 then
        new_pos_x = FIRST_PX_NEXT_SCREEN - self.w/2
      end

      if new_pos_y < (self.h/2 + HUD_HEIGHT) then
        new_pos_y = self.h/2 + HUD_HEIGHT
      end

      if new_pos_y > FIRST_PX_NEXT_SCREEN - self.h/2 then
        new_pos_y = FIRST_PX_NEXT_SCREEN - self.h/2
      end

      self.x = new_pos_x
      self.y = new_pos_y
      
      self.shoot_timer += (time() - last_time)
      local shot = btnp(key.a) -- or btnp(key.b)
      if self.shoot_timer > self.shoot_cooldown then        
        if shot then
          add(bullets, create_bullet(self.x, self.y, self.w, self.h))
          sfx(sound.shot)          
          self.shoot_timer = 0
        end
      end

      self.dmg_timer += (time() - last_time)
      if self.dmg_timer > self.dmg_cooldown and self.dmg_flick == true then
        self.dmg_flick = false
      end
      
      if self.state == 'flying' then
        if time() - self.anim > .3 then
          self.anim = time()
          self.sp += 2
          if self.sp > 3 then
            self.sp = 1
          end
        end
      elseif self.state == 'dying' then
        self.sp = 3
      end
    end,
    draw = function(self)
      if self.dmg_flick then 
        if self.dmg_flick_tick then
          self.dmg_flick_tick = false
          return
        else
          self.dmg_flick_tick = true
        end
      end
      draw_sprite(self)
    end,
    notify_collision = function(self, o)
      if o.type == type.carrot and self.life < 3 then
        self.life += 1
      elseif o.type == type.enemy or o.type == type.enemy_bullet or o.type == type.boss then
        if self.dmg_timer > self.dmg_cooldown then
          self.life -= 1
          self.dmg_timer = 0
          self.dmg_flick = true
        end        
      end
    end,
    is_dead = function(self)
      return (self.life <= 0) and true or false
    end,
  }
end

function create_cage(x, y)
  return {
    x = x,
    y = y,
    w = 16,
    h = 16,
    v = 1,
    sp = 42,
    active = false,
    draw = function(self)
      if self.active then
        draw_sprite(self)        
      end
    end,
  }
end

function create_princess(x, y)
  return {
    x = x,
    y = y,
    w = 16,
    h = 16,
    v = 1,
    sp = 96,
    anim = 0,    
    draw = function(self)
      draw_sprite(self)
    end,
  }
end

function create_heart(x, y)
  return {
    x = x,
    y = y,
    w = 8,
    h = 8,
    v = 1,
    sp = 81,
    anim = 0,    
    draw = function(self)
      draw_sprite(self)
    end,
  }
end

function create_bomb(x, y, behaviour)
 return {
   x = x,
   y = y,
   w = 16,
   h = 16,
   v = 1,
   sp = 33,
   anim = 0,
   life = 1,
   type = type.enemy,
   behaviour = behaviour and behaviour or {},
   update = function(self)
     if time() - self.anim > .3 then
       self.anim = time()
       self.sp += 2
       if self.sp > 35 then
         self.sp = 33
       end
     end

     if self.behaviour.type == 'up_down' then
       if self.behaviour.going_up then
         self.y -= self.v
        else
         self.y += self.v
       end

       if self.y > self.behaviour.start_y + self.behaviour.range then
        self.behaviour.going_up = true
       elseif self.y < self.behaviour.start_y - self.behaviour.range then
        self.behaviour.going_up = false
       end
     end

     self.x -= self.v
   end,
   draw = function(self)
     draw_sprite(self)
   end,
   notify_collision = function(self, o)
     if o.type == 'bullet' then
       self.life -= 1
     end
   end,
   is_dead = function(self)
     return (self.life <= 0) and true or false
   end,
  }
end

function create_fox(x, y, behaviour)
  return {
    x = x,
    y = y,
    w = 16,
    h = 16,
    v = 1,
    sp = 37,
    anim = 0,
    shoot_timer = 0,
    shoot_cooldown = 1,
    life = 1,
    type = type.enemy,
    behaviour = behaviour and behaviour or {},
    update = function(self)
      if time() - self.anim > .3 then
        self.anim = time()
        self.sp += 2
        if self.sp > 39 then
          self.sp = 37
        end
      end

      if self.behaviour.type == 'up_down' or self.behaviour.type == 'up_down_shoot' then
        if self.behaviour.going_up then
          self.y -= self.v
          else
          self.y += self.v
        end

        if self.y > self.behaviour.start_y + self.behaviour.range then
          self.behaviour.going_up = true
        elseif self.y < self.behaviour.start_y - self.behaviour.range then
          self.behaviour.going_up = false
        end
      end

      if self.behaviour.type == 'up_down_shoot' then
        self.shoot_timer += (time() - last_time)        
        if self.shoot_timer > self.shoot_cooldown then             
          add(bullets, create_enemy_bullet(self.x, self.y, self.w, self.h, 'fox'))               
          self.shoot_timer = 0
        end
      end

      self.x -= self.v
    end,
    draw = function(self)
      draw_sprite(self)
    end,
    notify_collision = function(self, o)
      if o.type == 'bullet' then
        self.life -= 1
      end
    end,
    is_dead = function(self)
      return (self.life <= 0) and true or false
    end
  }
end

function create_alien(x, y, behaviour)
 return {
    x = x,
    y = y,
    w = 16,
    h = 16,
    v = 1,
    sp = 132,
    anim = 0,
    shoot_timer = 0,
    shoot_cooldown = 1.3,
    life = 1,
    type = type.enemy,
    behaviour = behaviour and behaviour or {},
    update = function(self)
      if time() - self.anim > .3 then
        self.anim = time()
        self.sp += 2
        if self.sp > 134 then
          self.sp = 132
        end
      end

      if self.behaviour.type == 'shoot' then
        self.shoot_timer += (time() - last_time)        
        if self.shoot_timer > self.shoot_cooldown then             
          add(bullets, create_enemy_bullet(self.x, self.y, self.w, self.h, 'alien'))               
          self.shoot_timer = 0
        end
      end

      self.x -= self.v
    end,
    draw = function(self)
      draw_sprite(self)
    end,
    notify_collision = function(self, o)
      if o.type == 'bullet' then
        self.life -= 1
      end
    end,
    is_dead = function(self)
      return (self.life <= 0) and true or false
    end
  }
end

function create_meteor(x, y)
  return {
    x = x,
    y = y,
    w = 32,
    h = 32,
    v = 1,
    sp = 140,
    life = 2,
    type = type.enemy,
    update = function(self)
      self.x -= self.v
    end,
    draw = function(self)
      draw_sprite(self)
    end,
    notify_collision = function(self, o)
      if o.type == 'bullet' then
        self.life -= 1
        if self.life == 1 then
          self.sp = 204
        elseif self.life == 0 then
          add(enemies, create_meteor_sm(self.x, self.y))
          sfx(sound.explosion)
        end
      end
    end,
    is_dead = function(self)
      return (self.life <= 0) and true or false
    end,
  }
end

function create_meteor_sm(x, y)
  return {
    x = x,
    y = y,
    w = 16,
    h = 16,
    v = 1,
    sp = 128,
    life = 2,
    type = type.enemy,
    update = function(self)
      self.x -= self.v
    end,
    draw = function(self)
      draw_sprite(self)
    end,
    notify_collision = function(self, o)
      if o.type == 'bullet' then
        self.life -= 1
        if self.life == 1 then
          self.sp = 130
        elseif self.life == 0 then
          sfx(sound.explosion)
        end
      end
    end,
    is_dead = function(self)
      return (self.life <= 0) and true or false
    end,
  }
end

function create_boss(x, y)
  return {
    x = x,
    y = y ,
    w = 32,
    h = 32,
    v = 1,
    sp = 12,
    life = 30,
    active = false,
    going_up = true,
    range = 32,
    start_y = y - 8,
    type = type.boss,
    update = function(self)
      if self.active then
        if self.life > 20 then
          if self.going_up then
            self.y -= self.v
          else
            self.y += self.v
          end

          if self.y > self.start_y + self.range then
            self.going_up = true
          elseif self.y < self.start_y - self.range then
            self.going_up = false
          end
        end
      end
    end,
    draw = function(self)
      draw_sprite(self)      
      if self.life == 30 then
        spr(10, self.x  - (self.w/2) + 3, self.y - (self.h/2), 2, 2)
      end
      if self.active then
        local life_offset = self.life > 0 and ((self.life * 60) / 30) or 0
        rect(32, 98, 96, 110, 0)
        rectfill(34, 100, 34 + life_offset, 108, 6)
      end
    end,
    notify_collision = function(self, o)
      if o.type == 'bullet' then
        if self.life > 0 then    
          self.life -= 1
        end
        if self.life == 29 then
          self.active = true
        elseif self.life == 0 then
          add(foregrounds, create_explosion(self.x - 16 + rnd(32), self.y - 16 + rnd(32)))
          add(foregrounds, create_explosion(self.x - 16 + rnd(32), self.y - 16 + rnd(32)))
          add(foregrounds, create_explosion(self.x - 16 + rnd(32), self.y - 16 + rnd(32)))
          add(foregrounds, create_explosion(self.x - 16 + rnd(32), self.y - 16 + rnd(32)))
          add(foregrounds, create_explosion(self.x - 16 + rnd(32), self.y - 16 + rnd(32)))
          add(foregrounds, create_explosion(self.x - 16 + rnd(32), self.y - 16 + rnd(32)))
          add(foregrounds, create_explosion(self.x - 16 + rnd(32), self.y - 16 + rnd(32)))
          add(foregrounds, create_explosion(self.x - 16 + rnd(32), self.y - 16 + rnd(32)))  
          self.life = -1
        end
      end   
    end,
    is_dead = function(self)
      if self.life <= 0 and time_since_boss_death > 5 then
        return true
      else
        return false
      end
    end,
  }
end

function create_bullet(x, y, w, h)
  return {
    x = x + w/2,
    y = y + h/4,
    w = 8,
    h = 8,
    v = 3,
    sp = 16,
    life = 1,
    type = type.bullet,
    update = function(self)
      self.x += self.v
    end,
    draw = function(self)
      draw_sprite(self)
    end,
    notify_collision = function(self, o)
      if o.type == 'enemy' or o.type == 'boss' then
        self.life -= 1
      end
    end,
    is_dead = function(self)
      return (self.life <= 0) and true or false
    end,
  }
end

function create_enemy_bullet(x, y, w, h, shooter_type)
  local sp = 32
  if shooter_type == 'fox' then
    sp = 32
  elseif shooter_type == 'alien' then
    sp = 84
  elseif shooter_type == 'boss' then
    sp = 48
  end
  return {
    x = x - w/2,
    y = y + h/4,
    w = 8,
    h = 8,
    v = 2,
    sp = sp,
    life = 1,
    type = type.enemy_bullet,
    update = function(self)
      self.x -= self.v
    end,
    draw = function(self)
      draw_sprite(self)
    end,
    notify_collision = function(self, o)
      if o.type == 'player' then
        self.life -= 1
      end
    end,
    is_dead = function(self)
      return (self.life <= 0) and true or false
    end,
  }
end

function create_coin(x, y)
  return {
    x = x,
    y = y,
    w = 8,
    h = 8,
    v = 1,
    sp = 65,
    anim = 0,
    life = 1,
    type = type.coin,
    update = function(self)
      if time() - self.anim > .3 then
        self.anim = time()
        self.sp += 1
        if self.sp > 66 then
          self.sp = 65
        end
      end

      self.x -= self.v
    end,
    draw = function(self)
      draw_sprite(self)      
    end,
    notify_collision = function(self, o)
      if o.type == 'player' then
        coin_counter += 1
        self.life -= 1
        sfx(sound.coin)
      end
    end,
    is_dead = function(self)
      return (self.life <= 0) and true or false
    end,
  }
end

function create_carrot(x, y)
  return {
    x = x,
    y = y,
    w = 8,
    h = 8,
    v = 1,
    sp = 67,
    life = 1,
    type = type.carrot,
    update = function(self)
      self.x -= self.v
    end,
    draw = function(self)
      draw_sprite(self)      
    end,
    notify_collision = function(self, o)
      if o.type == 'player' then
        self.life -= 1
        sfx(sound.carrot)
      end
    end,
    is_dead = function(self)
      return (self.life <= 0) and true or false
    end,
    is = function(name)
      return name == 'carrot'
    end
  }
end

function create_explosion(x, y)
  return {
    x = x,
    y = y,
    w = 16,
    h = 16,
    v = 1,
    sp = 108,
    anim = 0,
    anim_count = 0,
    type = type.background,
    update = function(self)
      if time() - self.anim > .3 then
        self.anim = time()
        self.sp += 2
        self.anim_count += 1
        if self.anim_count >= 6 then
          del(backgrounds, self)
        end
        if self.sp > 110 then
          self.sp = 108
        end
      end

      if not boss then
        self.x -= self.v
      end
    end,
    draw = function(self)
      draw_sprite(self)      
    end,
    is_dead = function(self)   
    end
  }
end

function create_sm_cloud(x, y)
  return {
    x = x,
    y = y,
    w = 16,
    h = 8,
    v = 1,
    sp = 68,
    life = 1,
    type = type.background,
    update = function(self)
      self.x -= self.v
    end,
    draw = function(self)
      draw_sprite(self)      
    end,
    notify_collision = function(self, o)
    end,
    is_dead = function(self)
    end,
  }
end

function create_md_cloud(x, y)
  return {
    x = x,
    y = y,
    w = 32,
    h = 16,
    v = 1,
    sp = 70,
    life = 1,
    type = type.background,
    update = function(self)
      self.x -= self.v
    end,
    draw = function(self)
      draw_sprite(self)
    end,
    notify_collision = function(self, o)
    end,
    is_dead = function(self)
    end,
  }
end

function create_bg_transition_light(x, y, flip)
  return {
    x = x,
    y = y,
    w = 16,
    h = 8,
    v = 1,
    sp = 100,
    flip = flip,
    type = type.background,
    update = function(self)
      self.x -= self.v
    end,
    draw = function(self)
      spr(self.sp, self.x, self.y, self.w/8, self.h/8, self.flip)
    end,
  }
end

function create_bg_transition_medium(x, y, flip)
  return {
    x = x,
    y = y,
    w = 16,
    h = 8,
    v = 1,
    sp = 102,
    type = type.background,
    flip = flip,
    update = function(self)
      self.x -= self.v
    end,
    draw = function(self)
      spr(self.sp, self.x, self.y, self.w/8, self.h/8, self.flip)
    end,
  }
end

function create_bg_transition_dark(x, y, flip)
  return {
    x = x,
    y = y,
    w = 16,
    h = 8,
    v = 1,
    sp = 104,
    flip = flip,
    type = type.background,
    update = function(self)
      self.x -= self.v
    end,
    draw = function(self)
      spr(self.sp, self.x, self.y, self.w/8, self.h/8, self.flip)  
    end,
  }
end

function create_bg_dark(x, y)
  return {
    x = x,
    y = y,
    w = 8,
    h = 8,
    v = 1,
    sp = 64,
    type = type.background,
    update = function(self)
      self.x -= self.v
    end,
    draw = function(self)
      spr(self.sp, self.x, self.y, self.w/8, self.h/8)
      spr(self.sp, self.x + 8, self.y + 8, self.w/8, self.h/8)
    end,
  }
end

function create_bg_light(x, y)
  return {
    x = x,
    y = y,
    w = 8,
    h = 8,
    v = 1,
    sp = 80,
    type = type.background,
    update = function(self)
      self.x -= self.v
    end,
    draw = function(self)
      spr(self.sp, self.x, self.y, self.w/8, self.h/8)
    end,
  }
end

-- OTHER

function create_new_instances()
  -- START
  if scroll_distance == (TRANSITION_STARTS_PX - 128) then
    for i = 0, 13 do
      add(transitions, create_bg_transition_light(129, 16 + (i * 8)))
    end
  end

  if scroll_distance == (TRANSITION_STARTS_PX - 128) + 16 then
    for i = 0, 13 do
      add(transitions, create_bg_transition_medium(129, 16 + (i * 8)))
    end
  end

  if scroll_distance == (TRANSITION_STARTS_PX - 128) + 32 then
    for i = 0, 16 do
      for j = 0, 13 do
        if i == 0 then
          add(transitions, create_bg_transition_dark(129, 16 + (j * 8)))
        else
          add(transitions, create_bg_dark(129 + (i * 8), 16 + (j * 8)))
        end
      end
    end
  end

  -- FINISH
  if scroll_distance == TRANSITION_FINISH_PX - 128 then
    for i = 0, 13 do
      add(transitions, create_bg_transition_dark(129, 16 + (i * 8), true))
    end
  end

  if scroll_distance == (TRANSITION_FINISH_PX - 128) + 16 then
    for i = 0, 13 do
      add(transitions, create_bg_transition_medium(129, 16 + (i * 8), true))
    end
  end

  if scroll_distance == (TRANSITION_FINISH_PX - 128) + 32 then
    for i = 0, 16 do
      for j = 0, 13 do
        if i == 0 then
          add(transitions, create_bg_transition_light(129, 16 + (j * 8), true))
        else
          add(transitions, create_bg_light(129 + (i * 8), 16 + (j * 8)))
        end
      end
    end
  end

  if scroll_distance % 128 == 0 then    
    if scroll_distance < (TRANSITION_STARTS_PX - 128) or scroll_distance > (TRANSITION_FINISH_PX - 128) then
      local bgs = bg_patterns[next_bg_pattern]
      for b in all(bgs) do        
        add(backgrounds, copy_table(b))
      end
      next_bg_pattern = wrap_table(next_bg_pattern, rawlen(bg_patterns))      
    end

    local objs = future_objects[next_obj_pattern]
    for o in all(objs) do
      add(o.tb, o.o)
    end
    next_obj_pattern += 1
  end  

  -- END
  if scroll_distance == TRANSITION_FINISH_PX + 128 then
    boss = create_boss(128-16, 64)
  end
end

function check_collision()
  -- bullets
  for e in all(enemies) do
    for b in all(bullets) do
      if is_colliding(e, b) then
        e:notify_collision(b)
        b:notify_collision(e)
      end
    end
  end

  if boss then
    for b in all(bullets) do
      if is_colliding(boss, b) then
        boss:notify_collision(b)
        b:notify_collision(boss)
      end
    end
  end

  -- player
  for e in all(enemies) do
    if is_colliding(e, player) then
      e:notify_collision(player)
      player:notify_collision(e)
    end
  end

  for i in all(items) do
    if is_colliding(i, player) then
      i:notify_collision(player)
      player:notify_collision(i)
    end
  end

  for b in all(bullets) do
    if is_colliding(b, player) then
      b:notify_collision(player)
      player:notify_collision(b)
    end
  end
end

function check_is_dead()
  if player:is_dead() then
    init_game_over()
    _update = update_game_over
    _draw = draw_game_over
  end
  for b in all(bullets) do
    if b:is_dead() then
      del(bullets, b)
    end
  end
  for e in all(enemies) do
    if e:is_dead() then
      add(backgrounds, create_explosion(e.x, e.y))
      del(enemies, e)
    end
  end
  for i in all(items) do
    if i:is_dead() then
      del(items, i)
    end
  end
  for f in all(foregrounds) do
    if f:is_dead() then
      del(foregrounds, f)
    end
  end
  if boss then    
    if boss:is_dead() then
      boss = nil
      init_ending()
      _update = update_ending
      _draw = draw_ending
    end
  end
end

function delete_outside_boundries()
  for t in all(transitions) do
    if t.x < (t.w * -1) then
      del(transitions, t)
    end
  end

  for b in all(backgrounds) do
    if b.x < (b.w * -1) then
      del(backgrounds, b)
    end
  end

  for b in all(bullets) do
    if b.x < 0 or b.x > 128 or b.y < 0 or b.y > 128 then
      del(bullets, b)
    end
  end

  for e in all(enemies) do
    if e.x < (e.w * -1) then
      del(enemies, e)
    end
  end

  for i in all(items) do
    if i.x < (i.w * -1) then
      del(items, i)
    end
  end

  for f in all(foregrounds) do
    if f.x < (f.w * -1) then
      del(foregrounds, f)
    end
  end
end

function update_scroll_distance()
  scroll_distance += 1
end

function clear_screen()
  if scroll_distance < TRANSITION_STARTS_PX + 16 or scroll_distance > TRANSITION_FINISH_PX then
    cls(7)
  elseif scroll_distance > TRANSITION_STARTS_PX + 16 then
    cls(0)
  end
end

function draw_hud()
  for i = 0, 15 do
    spr(0, i * 8, 0)
    spr(0, i * 8, 8)
  end

  print("STAGE:", 17, 2)
  print("01", 43, 2)
  print("LIFE:", 17, 8)
  print(format_life(), 41, 8)
  print("TIME:", 73, 2)
  print(pad(""..flr(timer), 3), 99, 2)
  print("COINS:", 73, 8)
  print(pad(""..flr(coin_counter), 3), 99, 8)
end

function format_life()
  local life_str = ""
  for i=1, player.life do
    life_str = life_str .. "\135"
  end
  return life_str
end

function is_colliding(a, b)
  return a.x < (b.x + b.w) and (a.x + a.w) > b.x and a.y < (b.y + b.h) and (a.y + a.h) > b.y
end

function track_current_time()
  local cur_time = time()
  timer += cur_time - last_time

  if boss and boss.life <= 0 then
    time_since_boss_death += cur_time - last_time    
  end  
end

function track_last_time()
  last_time = time()
end

-- UTILS

function draw_sprite(o)
  spr(o.sp, o.x - (o.w/2), o.y - (o.h/2), o.w/8, o.h/8)
end

function print_centered(str, y, col)
  print(str, 64 - (#str * 2), y, col)
end

function print_katakana_centered(str, y, col)
  print(str, 64 - (#str * 3), y, col)
end

function wrap(current, max)
  if current + 1 > max then
    return 0
  end
  return current + 1
end

function wrap_table(current, max)
  if current + 1 > max then
    return 1
  end
  return current + 1
end

function pad(string, length)
  if (#string==length) return string
  return "0"..pad(string, length-1)
end

function sort(a)
  for i=1,#a do
    local j = i
    while j > 1 and a[j-1] > a[j] do
      a[j],a[j-1] = a[j-1],a[j]
      j = j - 1
    end
  end
end

function copy_table(t)
  local new_t = {}
  for key, value in pairs(t) do
    new_t[key] = value
  end
  return new_t
end

__gfx__
55555555e6666eeeeee6666e666eeeeeee666eee666666ee666666ee666666ee666666ee5555e55eee6666666666eeeeeeeee6666666666eeeeeeeeeee5555ee
55555555e6556eeeeee6556e65566eeeee65566e655566ee6e5556ee655566ee6e5556ee5555e555e660000000066eeeeeee666666666666eeeeeeeee555555e
55555555e6556eeeeee6556ee6556eeeeee6556e65e566eeeee656ee65e566eeeee656eee555e555e6000000000066eeeeee6eeeeeeeeee66eeeeee655555555
55555555e66666666666666ee66666666666666eeee666666666666eeee666666666666ee555e555605000000000066eeee6eeeee00eeeee66eeeee655555555
55555555e66555666665556ee66555666665556ee66666666666666ee66666666666666ee555e555600500500000006eeee6e5eee66ee5eee6eeeee650550500
55555555e05000500050005ee05000500050005ee66666666666666ee66666666666666eee55e55e6000500000000006eee6e55e000555eeee6eeee650000500
555555556050005000500056e05000500050005666606066666060666660606666606066eee5e5ee6000050000000006eee6e000555000eeee6eeee650000555
55555555e65000566650005ee65000566650005ee66606666666066ee66606666666066eeeeeeeee6005005000000006eee60eee060eee0eee65eee655005555
eeee00ee6665556606655566666555660665556e66606066066060666660606606606066eeeeeeee6000000500500065eee60ee6060ee60ee65555ee55555555
e055660ee66666666666666ee66666666666666ee66666666666666ee66666666666666eeeeeeeee6000000050000655eee60e6e060e6e0e6555555055555555
ee566660eeeee56555eeeeeeeeeee56555eeeeeeeeeee56555eeeeeeeeeee565556eeeeeeeeeeeee6000000005006555eee6e000555000e6555555550555555e
0556666066e00565550000eee6e00565550000ee66e00565550000ee66e00565550000eeee55e55e6000000500506555eee6ee5500555ee65555555550555eee
05566660e5000000000060556500000000006055e500000000006055e500000000006055e555e55e6000000000065555eee6eeee66666e65555555055eeeeeee
ee5666606600005555000055e60000555500005566000055550000556600005555000055e555e5ee5666000000655555eee566600066665555555550550eeeee
e055660ee5550005555000ee65550005555000eee5550005555000eee5550005555000eeeeeeeeee6555666666555555ee66555666666555555555555060eeee
eee000ee66eeee0000000eeee6eeee0000000eee66eeee0000000eee66eeee0000000eeeeeeeeeee6655555555555555e6666555555555555555555500060eee
eeeee0eeee066605055550eee055505066660eeee5eeeeeee5eeeeeee5eeeeeee5eeeeeeeeeeeeeee00000000000000e66660555556600060555555000060eee
eeeee0eee055505066660eeeee066605055550eee55eeee555e55066e55eeee555eeeeeeeeeeeeee000000000000000066000555566600066055555000060eee
ee000056eeeeee00eeeeeeeeeeeeee00eeeeeeeee555500000e66055e555500000e66055eeeeeeee005000500050050000000555566666666655550000060eee
e506505eeeeeee00eeeeeeeeeeeeee00eeeeeeeee060605750eee0eee060605750e55066eeeeeeee555eee5eee5ee55500000555566666666600000000060eee
0505605eeeeee5055eeeee5eeeeee5055eeeee5ee6066070706ee0eee6066070706ee0eeeeeeeeeeee5eee5eee5ee5ee66000555566600066055550006060eee
ee000056eee55055555ee500eee55055555ee500e0606057506ee0eee0606057506ee0eeeeeeeeeeee5eee5eee5ee5ee66660555556600060555555006060eee
eeeee0eeee5555555555666eee5555555555666ee55550000050e0eee55550000050e0eeeeeeeeeeee5eee5eee5ee5eee6666505555555555555555006060eee
eeeee0eeee55555555556600ee55555555556600ee5055555666050eee5055555666050eeeeeeeeeee5eee5eee5ee5eeee665555055555555555555000060eee
eeeeeeeee55765557655566ee55765557655566eeee6666666605506eee6666666605506eeeeeeeeee5eee5eee5ee5eeeeeeee5555550000000055550060eeee
e00000e0e0567555675506eee0567555675506ee555557700660550e555557700660550eeeeeeeeeee5eee5eee5ee5ee00eeee66555555555555055ee00eeeee
60000660e555577555555eeee555577555555eee5555570006660eee5555570006660eeeeeeeeeeeee5eee5eee5ee5ee0055556666605555555550eeeeeeeeee
60000060e055555555550eeee055555555550eee50057700666550ee50057700666550eeeeeeeeeeee5eee5eee5ee5ee00eeee6666600555555555eeeeeeeeee
60000060ee5555555555eeeeee5555555555eeeeeee00006655550eeeee00006655550eeeeeeeeee555555555555555500eeee66666000555555555eeeeeeeee
60000660ee0550505550eeeeee0550505550eeeeeeeee00555550eeeeeeee00555550eeeeeeeeeee005000500050050000555566666600055555555eeeeeeeee
e00000e0eee00505500eeeeeeee00505500eeeeeeeee05555550eeeeeeee05555550eeeeeeeeeeee000000000000000000eeee66666ee0055555555eeeeeeeee
eeeeeeeeeeeee0000eeeeeeeeeeee0000eeeeeeeeee00000000eeeeeeee00000000eeeeeeeeeeeeee00000000000000e0eeeee66eeeeeeee555555eeeeeeeeee
00000000eeeeeeeeeeeeeeeeeeee6e6eeeeeeeeeeeeeeeeeeeeeeeeeeeee666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000eeeee000eeeee0000eeee0000ee
00000000eeeeeeeeeeeeeeeeeeeee6e6eeeeeeeeeeeeeeeeeeeeeeeeee66eeeeee66eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0e00eeee06000eeee0600eeee0660e
00000000eee00eeeeee00eeeee55566eeeee6e6e6eeeeeeeeeeeeeeee6eeeeeeeeee66eeeeeeeeeeeeeeeeeeeeeeeeeeeee0600eeee0660eee00555000005550
00000000ee0660eeeee00eeee56765e6eee6e6e6e6eeeeeeeeeeeeee6eeeeeeeeeeeee6eeeeeeeeeeeeeeeeeeeeeeeeeee00555000005550ee656665666566e5
00000000ee0660eeeee00eeee57775eeee6e6e6e6e6eeeeeeeeeeee6eeeeeeeeeeeeeee6eeeeeeeeeeeeeeeeeeeeeeeeee656665666566e5ee65666566656e65
00000000eee00eeeeee00eee556765eee6e6e6e6e6e6e6eeeeeeee6eeeeeeeeeee66eee66eeeeeeeeeeeeeeeeeeeeeee0e65666566656e65000566650005ee65
00000000eeeeeeeeeeeeeeee55555eee6e6e6e6e6e6e6eeeeee666666eeeeeeee6eeeee666eeeeeeeeeeeeeeeeeeeeeee00566650005ee65ee00555006005550
00000000eeeeeeeeeeeeeeee555eeeeee6e6666666eee6e6ee6eeeeee6eeeeeeeeeeeee6666eeeeeeeeeeeeeeeeeeeeeee00555006005550e0e00000ee00000e
77777777eeeeeeeeeeeeeeeeee0000eeee6666eeee6666eee6eeeeeeeeeeeeeeeeeeeeee6666eeeeeeeeeeeeeeeeeeeee0e00000ee00000eeeeee000ee00eeee
77777777e00e00eeeeeeeeeee0eeee0ee667766ee667766e6eeeeeeeeeeeeeeeeeeeeeeee666eeeeeeeeeeeeeeeeeeee6eeee000ee00eeee6eee50055500eeee
777777770000000eeeeeeeee0ee00ee066557766667557666eeeeeeeeeeeeeeeeeeeeeeeeee666eeeeeeeeeeeeeeeeee65ee50055500eeee65e050055500eeee
777777770000000eeeeeeeee0e0eeee067566776677667766eeeeeeeeeeeeeeeeeeeeeeeeee6666eeeeeeeeeeeeeeeeee650500556006eeee65e500566006eee
77777777e00000eeeeeeeeee0e0eeee0677665766776677666eeeeeeeeeeeeeeeeeeeee666666666eeeeeeeeeeeeeeee66666506660566506666650666056650
77777777ee000eeeeeeeeeee0ee00ee06677556666755766e666eeeeeeeeeeeeeee66666666eeeeeeeeeeeeeeeeeeeeeee6666000066605eee6666000066605e
77777777eee0eeeeeeeeeeeee0eeee0ee667766ee667766eee666666666666666666666eeeeeeeeeeeeeeeeeeeeeeeeeeee6066000066eeeeee6066000066eee
77777777eeeeeeeeeeeeeeeeee0000eeee6666eeee6666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee065565eeeeeeeeee065565eeee
eeee666eee66eeeeeeeeeeeeeeeeeeee767776776766666665666566565555555055505505000000eeeeeeeeeeeeeeeeeeeee666666eeeeeeeeeeeeeeeeeeeee
eee66666e6666eeeeeeeeeeeeeeeeeee767776776766666665666566565555555055505505000000eeeeeeeeeeeeeeeeeeee6eeeeee6eeeeeeeeeeeeeeeeeeee
eee5566666665eeeeeeeeeeeeeeeeeee767776776766666665666566565555555055505505000000eeeeeeeeeeeeeeeeeee6eeeeeeee6eeeeeeeeeeeeeeeeeee
eeee55666665eeeeeeeeeeeeeeeeeeee767776776766666665666566565555555055505505000000eeeeeeeeeeeeeeeeee6eeeeeeeeee6eeeeeeee6666eeeeee
eeeee050505eeeeeeeeeeeeeeeeeeeee767776776766666665666566565555555055505505000000eeeeeeeeeeeeeeeee6eeeeeeeeeeee6eeeee6eeeeee6eeee
eee6666666666eeeeeeeeeeeeeeeeeee767776776766666665666566565555555055505505000000eeeeeeeeeeeeeeee66eeeeeeeeeeeee6eeeeeeeeeeeeeeee
ee666066666066eeeeeeeeeeeeeeeeee767776776766666665666566565555555055505505000000eeeeeeeeeeeeeeee6eeeeeeeeeeeeee6eee6eeeeeeee6eee
eee6606666606eeeeeeeeeeeeeeeeeee767776776766666665666566565555555055505505000000eeeeeeeeeeeeeeee6eeeeeeeeeeeeee6eee6eee66eee6eee
ee666666006666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000eeeeeeeeeeeeeeee6eeeeeeeeeeeeee6eee6eee66eee6eee
eee6666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee066666666666666666666660eeeeeeeeeeeeeeee6eeeeeeeeeeeeee6eee6eeeeeeee6eee
eeeeeee060eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee066666666666666666666660eeeeeeeeeeeeeeee6eeeeeeeeeeeeee6eeeeeeeeeeeeeeee
66eee60000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee066666666666666666666660eeeeeeeeeeeeeeeee6eeeeeeeeeeee6eeeee6eeeeee6eeee
55e555555555ee5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee066666666666666666666660eeeeeeeeeeeeeeeeee6eeeeeeeeee6eeeeeeee6666eeeeee
565550000555005eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee066666666666666666666660eeeeeeeeeeeeeeeeeee6eeeeeeee6eeeeeeeeeeeeeeeeeee
665555000055006eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee066666666666666666666660eeeeeeeeeeeeeeeeeeee6eeeeee6eeeeeeeeeeeeeeeeeeee
eee555555555ee6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000eeeeeeeeeeeeeeeeeeeee666666eeeeeeeeeeeeeeeeeeeee
eeee66eeeeeeeeeeeeee55eeeeeeeeeeeeee77777777eeeeeeee77777777eeee000000000e00e0e0eeeeeeeeeeeeeeeeeeeeeeee677777eeeeeeeee6566eeeee
eee67666eeeeeeeeeee56555eeeeeeeeeee7eeeeeeee7eeeeee7eeeeeeee7eee000000000e00e0e0eeeeeeeeeeeeeeeeeeeeee666666667eeeeeee766667eeee
ee6776666667eeeeee5665555556eeeeee7eeeeeeeeee7eeee7eeeeeeeeee7ee000000000e00e0e0eeeeeeeeeeeeeeeeeeeee66666666667ee66676666667eee
e677666566667eeee566555755556eeeee75eeeeeee5e7eeee75eeeeeee5e7ee000000000e00e0e0eeeeeeeeeeeeeeeeeeee66665566666676666666555666ee
67766666766666ee56655555655555eee7e65eeeee56ee7ee7e65eeeee56ee7e000000000e00e0e0eeeeeeeeeeeeeeeeeee7666575566665666666657755666e
56665666666666ee75557555555555eee7e555555555ee7ee7e555555555ee7e000000000e00e0e0eeeeeeeeeeeeeeeeee76667777566656666666677775566e
e56566666677666ee75755555566555ee7e576555765ee7ee7e576555765ee7e000000000e00e0e0eeeeeeeeeeeeeeeee766677775666566666666667777566e
766666666777766e655555555666655ee6e567555675ee6ee6e567555675ee6e000000000e00e0e0eeeeeeeeeeeeeeee7666777756666666666666666777666e
666666666777766e555555555666655ee7e555005555ee7ee7e555005555ee7e000000000e00e0e0eeeeeeeeeeeeeeee6667777566666666566666666666665e
666666666577566e555555555766755ee6ee5555555eee6ee6ee5555555eee6e000000000e00e0e0eeeeeeeeeeeeeeee6667776666666665656666665666555e
665666666655666e557555555577555ee6eee666666eee6ee6eee666666eee6e000000000e00e0e0eeeeeeeeeeeeeeee6666766666666666566666666555556e
e6667666666666eee5556555555555ee777e5566556ee777777e5566556ee777000000000e00e0e0eeeeeeeeeeeeeeee56666666666666666666666666666667
ee666666666667eeee555555555556ee77777777777777777777777777777777000000000e00e0e0eeeeeeeeeeeeeeee55666666666666666666666666666665
eeeeee5666667eeeeeeeee7555556eee66777777777777665577777777777755000000000e00e0e0eeeeeeeeeeeeeeeee5555556666666666666666666666666
eeeeeee56667eeeeeeeeeee75556eeeee66555666655566ee55666555566655e000000000e00e0e0eeeeeeeeeeeeeeeee5666666666666666666665666666666
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee665556655566eeee556665566655ee000000000e00e0e0eeeeeeeeeeeeeeeee6666666666666666666656666665666
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5555eeeeeeeeeeeeeeeeee56666666766666666666666666656566
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5555555eeeeeeeeeeeeeeee56666666676666666666666666665666
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55555ee55eee5eeeeeeeeeee55666666767666666666666666666666
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55e5eeeee5e55eeeeeeeeeeee5566666676666666666566666666666
ee00000000000000eeeee0000eeeeeee000eeee00eee00000eeeeee00eee00000eeeeee55e55eeeeeee55eeeeeeeeeeeee556666666766666665756666666666
ee000000000000000eeee0000eeeeee0000eee000ee0000000eeee000ee0000000eeeee5555eeeeeeeeeee5eeeeeeeeee7555666666666666657566666666666
e00000000000000000ee00000eeeeee0000eee000e000000000eee000e000000000eee05555eee5eeeeee5555eeeeeee66755566666666666575666666666666
e00000000000000000ee00000eeeeee0000eee00000000000000ee00000000000000e00555ee55555ee0055555eeeeee5666555666666666675766666666666e
0000000eeeee000000ee00000eeeeee0000eee00000000000000ee00000000000000e00055555555550000e555eeeeee5566555566666666666566667766667e
0000000eeeeeee0000ee00000eeeeee0000eee00000000000000ee00000000000000e00055055555550000ee555eeeee555665555666666666666666776666ee
0000000eeeeee00000ee00000eeeeee0000eee0000000ee00000ee0000000ee00000e00000555555500000ee555eeeee555565555566666666666666556667ee
0000000eeeeee00000ee00000eeeeee0000eee000000eeee0000ee000000eeee0000ee000055555500000eeee5eeeeeee5555555555566666666666666666eee
e000000eeeeeee0000ee00000eeeeee0000eee00000eeeee0000ee00000eeeee0000ee00000055500000eeeeeeeee5eeee55555555555557666666666666eeee
e000000eeeeeee0000ee00000eeeeee0000eee0000eeeeee0000ee0000eeeeee0000eee000005550000eeeeeeeee5e5eeee555555555555555766666666eeeee
e000000eeeee00000eee00000eeeeee0000eee0000eeeeee0000ee0000eeeeee0000eee00000555000eeeeeee5eee5eeeeee5555555555555555555666eeeeee
e000000eeee00000eeee00000eeeeee0000eee0000eeeeee0000ee0000eeeeee0000eeee000055500eeeeeeeeeeeeeeeeeeee5556eeeee65555555555eeeeeee
e000000ee00000000eee00000eeeeee0000eee0000eeeeee0000ee0000eeeeee0000eeee000005550eeeeeeeee5eeeeeeeeeeeee566666eeeeeeeee5755eeeee
e000000ee00000000eee00000eeeeee0000eee0000eeeeee0000ee0000eeeeee0000eeeee00005555eeeeeeeee5eeeeeeeeeee555555556eeeeeee655556eeee
e060000eeeeee00000ee06000eeeeee0000eee0000eeeeee0000ee0000eeeeee0000eeeee00000555eeeee5555eeeeeeeeeee55555555556ee55565555556eee
e006000eeeeee00000ee00600eeeeee0000eee0600eeeeee0000ee0600eeeeee0000eeeee006000555555555555eeeeeeeee55557755555565555555777555ee
e000600eeeeeee0000ee00000eeeeee0000eee0060eeeeee0000ee0060eeeeee0000eeeeee0060055555555555eee55eeee6555767755557555555576677555e
e000000eeeeeee0000ee00000eeeeee0000eee0000eeeeee0000ee0000eeeeee0000eeeeee000005e5555555eeee5555ee65556666755575555555566667755e
e000000eeeeeee0000ee00000eeeeee0000eee0000eeeeee0000ee0000eeeeee0000eeeee500000eee55555e5e5555e5e655566667555755555555556666755e
e000000eeeeeee0000ee00000eeeeee0000eee0000eeeeee0000ee0000eeeeee00006eee5500000eeeeeee5555e55e556555666675555555555555555666555e
e000000eeeeeee0000ee000000eeee00000eee0000eeeeee0000ee0000eeeeee000066655500000eeeeeeee55e55555e5556666755555555755555555555557e
e000000eeeeeee0000ee000000eeee00000eee0000eeeeee0000ee0000eeee66000066600500000eeeeeee5555555eee5556665555555557575555557555777e
e00000000000000000ee0000000ee000000eee0000eeeeee0000ee0000eee666000066600000000eeeeeeee55555eeee5555655555555555755555555777775e
e0000000000000000eee00000000000000eeee0000eeeeee0000ee0000ee666600006666000000eeeeeeeeeeeeeeeeee75555555555555555555555555555556
ee00000000000000eeeee0000000000000eeee0000eeeeee000eee0000e6666600066666660000eeeeeeeeeeeeeeeeee77555555555555555555555555555557
eeee00000000000eeeeeeee0000000000eeeee0000eeeeee000eee00006066660006666666600eeeeeeeeeeeeeeeeeeee7777775555555555555555555555555
eeeeeee000000eeeeeeeeeeee0000000eeeeee000eeeeeee00eeee0006660666006666666666eeeeeeeeeeeeeeeeeeeee7555555555555555555557555555555
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66666666666666666666eeeeeeeeeeeeeeeeeeeee5555555555555555555575555557555
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666666666666666666666eeeeeeeeeeeeeeeeeeee75555555655555555555555555575755
eeee000eeeee000eeee000000000eeeeee0000000000eeeeeeeeee666666666666666666666eeeeeeeeeeeeeeeeeeeee75555555565555555555555555557555
eee0000eeeee000eee000000000000eee000000000000eeeeeeee6066666666666666666666eeeeeeeeeeeeeeeeeeeee77555555656555555555555555555555
eee0000eeeee000eee00000eeee000eee000000000000eeeeeee6660666666666666666666eeeeeeeeeeeeeeeeeeeeeee7755555565555555555755555555555
eee0000eeeee000eee00000eeeee00eee00000eeeee00eeeeeee6666666666666666666666eeeeeeeeeeeeeeeeeeeeeeee775555555655555557675555555555
eee0000eeeee000eee0000eeeeee00eee0000eeeeee00eeeeee6666666666666666666666eeeeeeeeeeeeeeeeeeeeeeee6777555555555555576755555555555
eee0000eeeee000eee0000eeeeee00eee0000eeeeee00eeeeee666666666666666666666eeeeeeeeeeeeeeeeeeeeeeee55677755555555555767555555555555
eee00000eeee000eee0000eeeeee00eee0000eeee0000eeeee666666666666666666666eeeeeeeeeeeeeeeeeeeeeeeee7555777555555555567655555555555e
eee060000000000eee0600eeeeee00eee060000000000eeeee6666666666666666666eeeeeeeeeeeeeeeeeeeeeeeeeee7755777755555555555755556655556e
eee060000000000eee0600eeeeee00eee060000000000eeeee66666666666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeee777557777555555555555555665555ee
eee000000000000eee0000eeeeee00eee00000000000eeeeee666666666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777757777755555555555555775556ee
eee0000eeeee000eee0000eeeeee00eee0000eeeeeeeeeeeee6666666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777777777755555555555555555eee
eee0000eeeee000eee00000eeeee00eee0000eeeeeeeeeeeeee6666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77777777777776555555555555eeee
eee0000eeeee000eee00000eeee000eee0000eeeeeeeeeeeeeee666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777777777777777655555555eeeee
eee0000eeeee000eee00000000000eeee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777777777777777777555eeeeee
eee000eeeeee00eeeeee00000000eeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7775eeeee57777777777eeeeeee
__sfx__
00030000390303e0403e0403904039040390303903039030390303902039020390100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000024530225301e5301b5301753014530125300f5300c5300953007520025200052000300021000210000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000012620106200f6200b62008620066200362000620036000160000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000090500a0500b0500d0500f050140501805022050283000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002e0502b0502405029050290502905027050270502e050290502405024050270502905029050290502b0502b05029050290502905027050240502e0502b0502b050290502905029050290500000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00002000020000116300000000000116300000000000116302000011600116300000020000116302000020000116301160000000116300000000000116300000000000116300000000000116300000000000
000f0000290502903027050270302405024050220502205024050240501f0001f0501f050220502205024050240502700027000290502905027050270502405024050220502203022050220301d0501d05000000
010c0000270502705027050270500f6002705027050270502705018600270502705029050290502b0502b05029050290502705027050240502405022050220502b0502b050240502405000000000000000000000
__music__
00 44424344
00 01424344
00 01424344

