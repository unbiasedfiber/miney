
local SCALE = 5
local TILE_WIDTH = 21
local TILE_HEIGHT = 17

local grid = {won = false,
              win_time = 0,
              click = false,
              flag_click = false,
              cherry_click = true,
              pressing = false,
              block_matrix = {},
              block_images = {},
              bomb_total = 0,
              bombs_flagged = 0,
            };
local smiley = { x_pos = (TILE_WIDTH/2+.5)*7,
                 y_pos = 0, uhoh = nil, img = nil}

function grid:load()
  grid.tex_map = love.graphics.newImage("sweeper.png")

  grid.block_images[1] = love.graphics.newQuad(0,0,8,8,grid.tex_map:getDimensions())
  grid.block_images[2] = love.graphics.newQuad(8,0,8,8,grid.tex_map:getDimensions())
  grid.block_images[3] = love.graphics.newQuad(16,0,8,8,grid.tex_map:getDimensions())
  grid.block_images[4] = love.graphics.newQuad(24,0,8,8,grid.tex_map:getDimensions())

  grid.block_images[5] = love.graphics.newQuad(0,8,8,8,grid.tex_map:getDimensions())
  grid.block_images[6] = love.graphics.newQuad(8,8,8,8,grid.tex_map:getDimensions())
  grid.block_images[7] = love.graphics.newQuad(16,8,8,8,grid.tex_map:getDimensions())
  grid.block_images[8] = love.graphics.newQuad(24,8,8,8,grid.tex_map:getDimensions())

  grid.flag = love.graphics.newQuad(0,16,8,8,grid.tex_map:getDimensions())
  grid.bomb = love.graphics.newQuad(24,16,8,8,grid.tex_map:getDimensions())
  grid.empty = love.graphics.newQuad(16,16,8,8,grid.tex_map:getDimensions())
  grid.covered = love.graphics.newQuad(24,24,8,8,grid.tex_map:getDimensions())
  grid.pressed  = love.graphics.newQuad(16,24,8,8,grid.tex_map:getDimensions())

  grid.uhoh = love.graphics.newQuad(0,24,8,8,grid.tex_map:getDimensions())
  grid.smile  = love.graphics.newQuad(8,24,8,8,grid.tex_map:getDimensions())
  grid.happy  = love.graphics.newQuad(8,16,8,8,grid.tex_map:getDimensions())

  smiley.img  = grid.smile

  grid.start_time = love.timer.getTime()

  grid.block_matrix = grid:generate()
  grid:generate_bombs()
  grid:populate_numbers()

end

function grid:generate()
  block_matrix = {}
  for y = 1, TILE_HEIGHT do
    local row = {}
    for x = 0, TILE_WIDTH do
      local block = {x_pos = x*7, y_pos = y*7,
                     tl = nil, tm = nil, tr = nil,
                     l = nil, m = nil, r = nil,
                     bl = nil, bm = nil, br = nil,
                     value = 0,
                     bomb = false,
                     clicked = false,
                     img = grid.covered, uncover_img = nil,
                    };
      table.insert(row, block)
    end
    table.insert(block_matrix, row)
  end
  return block_matrix
end

function grid:generate_bombs()
  for k,row in pairs(self.block_matrix) do
    for v, block in pairs(row) do
      local int = math.random(0,4)
      if int>3 then
        block.uncover_img = grid.bomb
        block.bomb = true
        grid.bomb_total = grid.bomb_total+1
      end
    end
  end
end

function grid:populate_numbers()
  for k,row in pairs(self.block_matrix) do
    for v, block in pairs(row) do

      if v>1 and k>1 then
        block.tl = self.block_matrix[k-1][v-1]
        if block.tl.bomb then block.value = block.value+1 end
      else block.tl = nil end

      if v>1 then block.l  = row[v-1]
        if block.l.bomb then block.value = block.value+1 end
      else block.l = nil end

      if v>1 and k<#self.block_matrix then block.bl = self.block_matrix[k+1][v-1]
        if block.bl.bomb then block.value = block.value+1 end
      else block.bl = nil end

      if k>1 then block.tm = self.block_matrix[k-1][v]
        if block.tm.bomb then block.value = block.value+1 end
      else block.tm = nil end

      if k<#self.block_matrix then block.bm = self.block_matrix[k+1][v]
        if block.bm.bomb then block.value = block.value+1 end
      else block.bm = nil end

      if v<#row and k>1 then block.tr = self.block_matrix[k-1][v+1]
        if block.tr.bomb then block.value = block.value+1 end
      else block.tr = nil end

      if v<#row then block.r  = row[v+1]
        if block.r.bomb then block.value = block.value+1 end
      else block.r = nil end

      if v<#row and k<#self.block_matrix then block.br = self.block_matrix[k+1][v+1]
        if block.br.bomb then block.value = block.value+1 end
      else block.br = nil end

      if not block.bomb then
        if block.value < 1 then block.uncover_img = grid.empty
        else block.uncover_img = self.block_images[block.value] end
      else block.value = math.huge
      end
    end
  end
end

function grid:scan(clicked)
  --recursively eliminate empty block spaces.
  clicked.clicked = true

  if clicked.tl and not clicked.tl.clicked and clicked.tl.img ~= grid.flag then
    if clicked.tl.value<1 then self:scan(clicked.tl)
    else clicked.tl.clicked = true
    end
  end
  if clicked.tm and not clicked.tm.clicked and clicked.tm.img ~= grid.flag then
    if clicked.tm.value<1 then self:scan(clicked.tm)
    else clicked.tm.clicked = true
    end
  end
  if clicked.tr and not clicked.tr.clicked and clicked.tr.img ~= grid.flag then
    if clicked.tr.value<1 then self:scan(clicked.tr)
    else clicked.tr.clicked = true
    end
  end
  if clicked.l and not clicked.l.clicked and clicked.l.img ~= grid.flag then
     if clicked.l.value<1 then self:scan(clicked.l)
     else clicked.l.clicked = true
     end
  end
  if clicked.r and not clicked.r.clicked and clicked.r.img ~= grid.flag then
     if clicked.r.value<1  then self:scan(clicked.r)
     else clicked.r.clicked = true
     end
  end
  if clicked.bl and not clicked.bl.clicked and clicked.bl.img ~= grid.flag then
     if clicked.bl.value<1 then self:scan(clicked.bl)
     else clicked.bl.clicked = true
     end
  end
  if clicked.bm and not clicked.bm.clicked and clicked.bm.img ~= grid.flag then
     if clicked.bm.value<1 then self:scan(clicked.bm)
     else clicked.bm.clicked = true
     end
  end
  if clicked.br and not clicked.br.clicked and clicked.br.img ~= grid.flag then
     if clicked.br.value<1 then self:scan(clicked.br)
     else clicked.br.clicked = true
     end
  end
  return
end

function grid:update()
  if love.mouse.isDown(1) then
    grid:press()
  elseif love.mouse.isDown(2) and not grid.flag_click then
    grid:get_click(true)
    grid.flag_click = true
  elseif grid.pressing and not love.mouse.isDown(1) and not love.mouse.isDown(2) then
    grid:get_click(false)
    grid.pressing = false
  elseif not love.mouse.isDown(1) and not love.mouse.isDown(2) then
    grid.pressing = false
    grid.flag_click = false
  end
end

function grid:draw_blocks()
  for k, row in pairs(grid.block_matrix) do
    for v, block in pairs(row) do
      if block.clicked then
        love.graphics.draw(grid.tex_map, block.uncover_img, block.x_pos, block.y_pos)
      else
        love.graphics.draw(grid.tex_map, block.img, block.x_pos, block.y_pos)
      end
    end
  end
end

function grid:check_block(mouse_x, mouse_y, flag)
  if ( mouse_x > smiley.x_pos
   and mouse_x < smiley.x_pos+8
   and mouse_y > smiley.y_pos
   and mouse_y < smiley.y_pos+8 )
   then
     grid:restart()
     return
  else
    for k,row in pairs(self.block_matrix) do
      for v, block in pairs(row) do
        if ( mouse_x > block.x_pos
         and mouse_x < block.x_pos+8
         and mouse_y > block.y_pos
         and mouse_y < block.y_pos+8 )
          then
            if flag then
              if block.img ~= grid.flag then
                block.img = grid.flag
                if block.bomb then grid.bombs_flagged = grid.bombs_flagged+1
                end
              else block.img = grid.covered
                if block.bomb then grid.bombs_flagged = grid.bombs_flagged-1
                end
              end
            else
              if block.bomb and block.img ~= grid.flag then
                if grid.cherry_click then
                  grid:cherry_restart(block.x_pos, block.y_pos)
                  grid.cherry_click = false
                else
                  self:game_over()
                end
              else
                grid.cherry_click = false
                if block.img ~= grid.flag then
                  block.clicked = true
                  if block.value < 1 then self:scan(block)
                  end
                end
              end
            end
        end
      end
    end
  end
  print(grid.won, grid.bombs_flagged, grid.bomb_total)
  if grid.bombs_flagged == grid.bomb_total then
    grid:win()
  end
end

function grid:get_click(flag)
  local x, y = love.mouse.getPosition()
  grid:check_block(x/SCALE, y/SCALE, flag)
end

function grid:press()
  self.pressing = true

  local mouse_x, mouse_y = love.mouse.getPosition()
  if ( mouse_x/SCALE > smiley.x_pos
   and mouse_x/SCALE < smiley.x_pos+8
   and mouse_y/SCALE > smiley.y_pos
   and mouse_y/SCALE < smiley.y_pos+8 )
   then
     print("res")
     smiley.img = grid.uhoh
  else smiley.img = grid.smile
  end
  for k,row in pairs(self.block_matrix) do
    for v, block in pairs(row) do
      if ( mouse_x/SCALE > block.x_pos
       and mouse_x/SCALE < block.x_pos+8
       and mouse_y/SCALE > block.y_pos
       and mouse_y/SCALE < block.y_pos+8 )
        then
          if block.img ~= grid.flag then
            block.img = grid.pressed
          end
      else
        if not block.clicked and block.img ~= grid.flag then block.img = grid.covered end
      end
    end
  end
end

function grid:game_over()
  smiley.img = grid.uhoh
  for k,row in pairs(self.block_matrix) do
    for v, block in pairs(row) do
      block.clicked = true
    end
  end
end

function grid:restart()
  smiley.img = grid.smile
  grid.won = false
  grid.bomb_total = 0
  grid.bombs_flagged = 0
  grid.start_time = love.timer.getTime()
  grid.cherry_click = true
  grid.block_matrix = grid:generate()
  grid:generate_bombs()
  grid:populate_numbers()
end

function grid:cherry_restart(x_pos, y_pos)
  smiley.img = grid.smile
  grid.won = false
  grid.bomb_total = 0
  grid.bombs_flagged = 0
  grid.start_time = love.timer.getTime()
  grid.block_matrix = grid:generate()
  grid:generate_bombs()
  for k,row in pairs(self.block_matrix) do
    for v, block in pairs(row) do
      if block.x_pos == x_pos
      and block.y_pos == y_pos then
        block.bomb = false
        block.clicked = true
        grid.bomb_total = grid.bomb_total+1
        if v+1<#row then
          row[v+1].bomb = true
          row[v+1].uncover_img = grid.bomb
        elseif v-1>0 then
          row[v-1].bomb = true
          row[v-1].uncover_img = grid.bomb
        end
      end
    end
  end
  grid:populate_numbers()
end

function grid:win()
  smiley.img = grid.happy
  grid.won = true
  grid.win_time = love.timer.getTime() - grid.start_time
end

function grid:draw_smiley()
  love.graphics.draw(grid.tex_map, smiley.img, smiley.x_pos, smiley.y_pos)
end

function grid:draw_timer()
  local result = love.timer.getTime() - grid.start_time
  if grid.won then
    love.graphics.print(string.format( "%4.f", grid.win_time), 0, 0)
  elseif result < 999.0 then
    love.graphics.print(string.format( "%4.f", result), 0, 0)
  end
end

---------------------------



function love.load()

  love.graphics.setDefaultFilter("nearest")
  local font = love.graphics.newFont("fonts/slkscre.ttf", 8)
  love.graphics.setFont(font)
  grid:load()

end

function love.update(dt)
  grid:update()
end

function love.draw()
  love.graphics.scale(SCALE, SCALE)
  grid:draw_blocks()
  grid:draw_smiley()
  grid:draw_timer()
end
