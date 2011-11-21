local naughty= require("naughty")
local cairo=require("oocairo")
local string = require("string")
local math = math
local table = table
module("blingbling.helpers")

widget_index={}

function dbg(vars)
  local text = ""
  for i=1, #vars do text = text .. vars[i] .. " | " end
  naughty.notify({ text = text, timeout = 15 })
end

function hexadecimal_to_rgba_percent(my_color)
  --check if color is a valid hex color else return white
  if string.find(my_color,"#[0-f][0-f][0-f][0-f][0-f]") then
  --delete #
    my_color=string.gsub(my_color,"^#","")
    r=string.format("%d", "0x"..string.sub(my_color,1,2))
    v=string.format("%d", "0x"..string.sub(my_color,3,4))
    b=string.format("%d", "0x"..string.sub(my_color,5,6))
    if string.sub(my_color,7,8) == "" then
      a=255
    else
      a=string.format("%d", "0x"..string.sub(my_color,7,8))
    end
  else
    r=255
    v=255
    b=255
    a=255
   end
  return r/255,v/255,b/255,a/255
end

function split(str, pat)
  local t = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = string.find(str,fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t,cap)
    end
    last_end = e+1
    s, e, cap = string.find(str,fpat, last_end)
  end
  if last_end <= #str then
    cap = string.sub(str,last_end)
    table.insert(t, cap)
  end
  return t
end
function draw_background_tiles(cairo_context, height, v_margin , width, h_margin)
--tiles: width 4 px height 2px horizontal separator=1 px vertical separator=2px
--			v_separator
--		 _______\ /_______
--		|_______| |_______| 
--	 	 _______   _______  <--h_separator
--		|_______| |_______|	<--tiles_height
--		/        \
--		tiles_width
   
  tiles_width=4
  tiles_height=2
  h_separator=1
  v_separator=2
--find nb max horizontal lignes we can display with 2 pix squarre and 1 px separator (3px)
  local max_line=math.floor((height - v_margin*2) /(tiles_height+h_separator))
  --what to do with the rest of the height:
  local h_rest=(height - v_margin*2) - (max_line * (tiles_height+h_separator))
  if h_rest >= (tiles_height) then 
     max_line= max_line + 1
     h_rest= h_rest - tiles_height
  end
  if h_rest > 0 then
	  h_rest =h_rest / 2
  end	
  --find nb columns we can draw with tile of 4px width and 2 px separator (6px) and center them horizontaly
  local max_column=math.floor((width - h_margin*2)/6)
  local v_rest=(width- h_margin*2)-(max_column*( tiles_width + v_separator))
  if v_rest >= (tiles_width) then 
    max_column= max_column + 1
    v_rest= v_rest - tiles_width
  end
  if v_rest > 0 then
	  h_rest =h_rest / 2
  end	
  
  x=width-(tiles_width + v_rest)
  y=height -(v_margin +tiles_height + h_rest) 
  for i=1,max_column do
    for j=1,max_line do
      cairo_context:rectangle(x,y,4,2)
      y= y-(tiles_height + h_separator)
    end
      y=height -(v_margin + tiles_height + h_rest) 
      x=x-(tiles_width + v_separator)
  end
end

function draw_text_and_background(cairo_context, text, x, y, background_text_color, text_color, show_text_centered_on_x, show_text_centered_on_y, show_text_on_left_of_x, show_text_on_bottom_of_y)
    --Text background
    ext=cairo_context:text_extents(text)
    x_modif = 0
    y_modif = 0
    
    if show_text_centered_on_x == true then
      x_modif = ((ext.width + ext.x_bearing) / 2) + ext.x_bearing / 2 
      show_text_on_left_of_x = false
    else
      if show_text_on_left_of_x == true then
        x_modif = ext.width + 2 *ext.x_bearing     
      else 
        x_modif = x_modif
      end
    end
    
    if show_text_centered_on_y == true then
      y_modif = ((ext.height +ext.y_bearing)/2 ) + ext.y_bearing / 2
      show_text_on_left_of_y = false
      --dbg({y_modif})
    else
      if show_text_on_bottom_of_y == true then
        y_modif = ext.height + 2 *ext.y_bearing     
      else 
        y_modif = y_modif
      end
    end
    cairo_context:rectangle(x + ext.x_bearing - x_modif,y + ext.y_bearing - y_modif,ext.width, ext.height)
    r,g,b,a=hexadecimal_to_rgba_percent(background_text_color)
    cairo_context:set_source_rgba(r,g,b,a)
    cairo_context:fill()
    --Text
    cairo_context:new_path()
    cairo_context:move_to(x-x_modif,y-y_modif)
    r,g,b,a=hexadecimal_to_rgba_percent(text_color)
    cairo_context:set_source_rgba(r, g, b, a)
    cairo_context:show_text(text)
end

function draw_up_down_arrows(cairo_context,x,y_bottom,y_top,value,background_arrow_color, arrow_color, arrow_line_color,up)
    if up ~= false then 
      invert = 1
    else
      invert= -1
    end
    --Draw the background arrow
    cairo_context:move_to(x,y_bottom)
    cairo_context:line_to(x,y_top )
    cairo_context:line_to(x-(6 * invert), y_top + (6 * invert))
    cairo_context:line_to(x-(3*invert), y_top + (6 * invert))
    cairo_context:line_to(x-(3*invert), y_bottom)
    cairo_context:line_to(x,y_bottom)
    cairo_context:close_path()
    cairo_context:set_source_rgba(0, 0, 0, 0.3)
    cairo_context:fill()
    --Draw the arrow if value is > 0
    if value > 0 then
      cairo_context:move_to(x,y_bottom)
      cairo_context:line_to(x,y_top )
      cairo_context:line_to(x-(6*invert), y_top + (6 * invert))
      cairo_context:line_to(x-(3*invert), y_top + (6 * invert))
      cairo_context:line_to(x-(3*invert), y_bottom)
      cairo_context:line_to(x,y_bottom)
      cairo_context:close_path()
      cairo_context:set_source_rgba(0.5, 0.7, 0.1, 0.7)
      cairo_context:fill()
      cairo_context:move_to(x,y_bottom)
      cairo_context:line_to(x,y_top )
      cairo_context:line_to(x-(6*invert), y_top + (6 * invert))
      cairo_context:line_to(x-(3*invert), y_top + (6 * invert))
      cairo_context:line_to(x-(3*invert), y_bottom)
      cairo_context:line_to(x,y_bottom)
      cairo_context:close_path()
      cairo_context:set_source_rgba(0.5, 0.7, 0.1, 0.7)
      cairo_context:set_line_width(1)
      cairo_context:stroke()
  end
end

function draw_vertical_bar(cairo_context,h_margin,v_margin, width,height, represent)
  x=h_margin
  bar_width=width - 2*h_margin
  bar_height=height - 2*v_margin
  y=v_margin 
  if represent["background_bar_color"] == nil then
    r,g,b,a = hexadecimal_to_rgba_percent("#000000")
  else
    r,g,b,a = hexadecimal_to_rgba_percent(represent["background_bar_color"])
  end

  cairo_context:rectangle(x,y,bar_width ,bar_height)
  gradient=cairo.pattern_create_linear(h_margin, height/2, width-h_margin, height/2)
  gradient:add_color_stop_rgba(0, r, g, b, 0.5)
  gradient:add_color_stop_rgba(0.5, 1, 1, 1, 0.5)
  gradient:add_color_stop_rgba(1, r, g, b, 0.5)
  cairo_context:set_source(gradient)
  cairo_context:fill()
  if represent["value"] ~= nil and represent["color"] ~= nil then
    x=h_margin
    bar_width=width - 2*h_margin
    bar_height=height - 2*v_margin
    if represent["invert"] == true then
      y=v_margin 
    else
      y=height - (bar_height*represent["value"] + v_margin )
    end
    cairo_context:rectangle(x,y,bar_width,bar_height*represent["value"])
    r,g,b,a = hexadecimal_to_rgba_percent(represent["color"])
    gradient=cairo.pattern_create_linear(0, height/2,width, height/2)
    gradient:add_color_stop_rgba(0, r, g, b, 0.1)
    gradient:add_color_stop_rgba(0.5, r, g, b, 1)
    gradient:add_color_stop_rgba(1, r, g, b, 0.1)
    cairo_context:set_source(gradient)
    cairo_context:fill()
  end  
end
function draw_horizontal_bar( cairo_context,h_margin,v_margin, width, height, represent)
  x=h_margin
  bar_width=width - 2*h_margin
  bar_height=height - 2*v_margin
  y=v_margin 
  if represent["background_bar_color"] == nil then
    r,g,b,a = hexadecimal_to_rgba_percent("#000000")
  else
    r,g,b,a = hexadecimal_to_rgba_percent(represent["background_bar_color"])
  end
  cairo_context:rectangle(x,y,bar_width,bar_height)
  gradient=cairo.pattern_create_linear( width /2,v_margin , width/2, height - v_margin)
  gradient:add_color_stop_rgba(0, r, g, b, 0.5)
  gradient:add_color_stop_rgba(0.5, 1, 1, 1, 0.5)
  gradient:add_color_stop_rgba(1, r, g, b, 0.5)
  cairo_context:set_source(gradient)
  cairo_context:fill()
  if represent["value"] ~= nil and represent["color"] ~= nil then
    x=h_margin
    bar_width=width - 2*h_margin
    bar_height=height - 2*v_margin
    if represent["invert"] == true then
      x=width - (h_margin + bar_width*represent["value"] )
    else
      x=h_margin
    end
    cairo_context:rectangle(x,y,bar_width*represent["value"],bar_height)
    r,g,b,a = hexadecimal_to_rgba_percent(represent["color"])
    gradient=cairo.pattern_create_linear(width /2,0 , width/2, height)
    gradient:add_color_stop_rgba(0, r, g, b, 0.1)
    gradient:add_color_stop_rgba(0.5, r, g, b, 1)
    gradient:add_color_stop_rgba(1, r, g, b, 0.1)
    cairo_context:set_source(gradient)
    cairo_context:fill()
  end  
end
function draw_rounded_corners_rectangle(cairo_context,x,y,width, height, color, rounded_size)
--if rounded_size =0 it is a classical rectangle (whooooo!)  
  local height = height
  local width = width
  local x = x
  local y = y
  local rounded_size = rounded_size or 0.4
  if height > width then
    radius=0.5 * width
  else
    radius=0.5 * height
  end

  PI = 2*math.asin(1)
  r,g,b,a=hexadecimal_to_rgba_percent(color)
  cairo_context:set_source_rgba(r,g,b,a)
  --top left corner
  cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
  --top right corner
  cairo_context:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI * 2)
  --bottom right corner
  cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0, PI * 0.5)
  --bottom left corner
  cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
  cairo_context:close_path()
  cairo_context:fill()

end
function draw_rounded_corners_horizontal_graph(cairo_context,x,y,width, height, background_color, graph_color, rounded_size, value_to_represent, graph_line_color)
--if rounded_size =0 it is a classical rectangle (whooooo!)  
  local height = height
  local width = width
  local x = x
  local y = y
  local rounded_size = rounded_size or 0.4
  if height > width then
    radius=0.5 * width
  else
    radius=0.5 * height
  end

  PI = 2*math.asin(1)
  --draw the background
  r,g,b,a=hexadecimal_to_rgba_percent(background_color)
  cairo_context:set_source_rgba(r,g,b,a)
  --top left corner
  cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
  --top right corner
  cairo_context:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI * 2)
  --bottom right corner
  cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0, PI * 0.5)
  --bottom left corner
  cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
  cairo_context:close_path()
  cairo_context:fill()
  --represent the value
  -- value in 0 -> 1
  --  radius*rounded_size |  width - 2*( radius*rounded) | radius * rounded_size
  --                  |               |                         |
  --                  |      _________|  _______________________|
  --                  |     |           |
  --                  v ____v_________  v
  --                  /|              |\
  --                 | |              | |               (... and yes I don't have a job)
  --                  \|______________|/
  --
  --1 => width/ width
  --limit_2 => width -radius / width
  --limit_1 => radius /width
  value = value_to_represent
  limit_2 = (width -(radius * rounded_size)) / width
  limit_1 = radius* rounded_size /width

  r,g,b,a=hexadecimal_to_rgba_percent(graph_color)
  cairo_context:set_source_rgba(r,g,b,a)
 
  if value <= 1 and value > limit_2 then
    cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
    ratio = (value - limit_2) / (1 - limit_2)
    cairo_context:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI *(1.5 +(0.5  * ratio)))
    cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*(0.5 - (0.5 * ratio))  , PI * 0.5)
    cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
    cairo_context:close_path()
    cairo_context:fill()
  elseif value <= limit_2 and value > limit_1 then
    cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
    ratio = value  / limit_2
    cairo_context:line_to(limit_2*width*ratio,y)
    cairo_context:line_to(limit_2*width*ratio,height)
    cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
    cairo_context:close_path()
    cairo_context:fill()
  elseif value <= limit_1 and value > 0 then
    ratio = value  / limit_1
    cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * (1+ (0.5*ratio)))
    cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*(1-(0.5 * ratio)) , PI * 1)
    cairo_context:close_path()
    cairo_context:fill()
  end
  if graph_line_color then
    r,g,b,a=hexadecimal_to_rgba_percent(graph_color)
    cairo_context:set_source_rgba(r,g,b,a)
    cairo_context:set_line_width(1)

    if value <= 1 and value > limit_2 then
      cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
      ratio = (value - limit_2) / (1 - limit_2)
      cairo_context:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI *(1.5 +(0.5  * ratio)))
      cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*(0.5 - (0.5 * ratio))  , PI * 0.5)
      cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cairo_context:close_path()
      cairo_context:stroke()
    elseif value <= limit_2 and value > limit_1 then
      cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
      ratio = value  / limit_2
      cairo_context:line_to(limit_2*width*ratio,y)
      cairo_context:line_to(limit_2*width*ratio,height)
      cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cairo_context:close_path()
      cairo_context:stroke()
    elseif value <= limit_1 and value > 0 then
      ratio = value  / limit_1
      cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * (1+ (0.5*ratio)))
      cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*(1-(0.5 * ratio)) , PI * 1)
      cairo_context:close_path()
      cairo_context:stroke()
    end
  end
end
function draw_rounded_corners_vertical_graph(cairo_context,x,y,width, height, background_color, graph_color, rounded_size, value_to_represent, graph_line_color)
--if rounded_size =0 it is a classical rectangle (whooooo!)  
  local height = height
  local width = width
  local x = x
  local y = y
  if rounded_size == nil or rounded_size == 0 then
    --draw the background:
    r,g,b,a=hexadecimal_to_rgba_percent(background_color)
    cairo_context:set_source_rgba(r,g,b,a)
    cairo_context:move_to(x,y)
    cairo_context:line_to(x,height)
    cairo_context:line_to(width,height)
    cairo_context:line_to(width,y)
    cairo_context:close_path()
    cairo_context:fill()
    --draw the graph:
    r,g,b,a=hexadecimal_to_rgba_percent(graph_color)
    cairo_context:set_source_rgba(r,g,b,a)
    cairo_context:move_to(x,height)
    cairo_context:line_to(x, height -((height -y)* value_to_represent)  )
    cairo_context:line_to(width,height -((height - y)*value_to_represent) )
    cairo_context:line_to(width,height)
    cairo_context:close_path()
    cairo_context:fill()
    if graph_line_color then
      r,g,b,a=hexadecimal_to_rgba_percent(graph_line_color)
      cairo_context:set_source_rgba(r,g,b,a)
      cairo_context:move_to(x,height)
      cairo_context:line_to(x,height -((height -y)* value_to_represent) )
      cairo_context:line_to(width,height -((height -y)*value_to_represent) )
      cairo_context:line_to(width,height)
      cairo_context:close_path()
      cairo_context:set_line_width(1)
      cairo_context:stroke()
    end
  else
    local rounded_size = rounded_size or 0.4
    if height > width then
      radius=0.5 * width
    else
      radius=0.5 * height
    end

    PI = 2*math.asin(1)
    --draw the background
    r,g,b,a=hexadecimal_to_rgba_percent(background_color)
    cairo_context:set_source_rgba(r,g,b,a)
    --top left corner
    cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
    --top right corner
    cairo_context:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI * 2)
    --bottom right corner
    cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0, PI * 0.5)
    --bottom left corner
    cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
    cairo_context:close_path()
    cairo_context:fill()
    --represent the value
    -- value in 0 -> 1
    --  radius*rounded_size |  height - 2*( radius*rounded) | radius * rounded_size
    --                  |               |                         |
    --                  |           ____|  _______________________|
    --                  |_______   |      |     
    --                   ___    |  |      |
    --                  /___\ <-   |      |
    --                 |     |     |      |
    --                 |     |<----       |
    --                 |_____|            |
    --                  \___/<------------
    --
    --1 => height/ height
    --limit_2 => height -radius / height
    --limit_1 => radius /height
    value = value_to_represent
    limit_2 = (height -(radius * rounded_size)) / height
    limit_1 = radius* rounded_size /height
    --dbg({value, limit_2, limit_1})
    r,g,b,a=hexadecimal_to_rgba_percent(graph_color)
    cairo_context:set_source_rgba(r,g,b,a)
 
    if value <= 1 and value > limit_2 then
      ratio = (value - limit_2) / (1 - limit_2)
      cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0  , PI * 0.5)
      cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * (1+(0.5* ratio)) )
      cairo_context:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*(2 -(0.5* ratio)), PI *2)
      cairo_context:close_path()
      cairo_context:fill()
    elseif value <= limit_2 and value > limit_1 then
      ratio = value  / limit_2
      cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0  , PI * 0.5)
      cairo_context:arc(x + radius*rounded_size,height - radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cairo_context:line_to(x,y + height - (height * ratio*limit_2) )
      cairo_context:line_to(width,y+ height - (height * ratio*limit_2) )
      cairo_context:close_path()
      cairo_context:fill()

    elseif value <= limit_1 and value > 0 then
      ratio = value  / limit_1
      cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*(0.5-( 0.5*ratio))  , PI * 0.5)
      cairo_context:arc(x + radius*rounded_size,height - radius*rounded_size, radius*rounded_size,PI*0.5, PI *(0.5+ (0.5*ratio)))
      cairo_context:close_path()
      cairo_context:fill()
    end
    if graph_line_color then
      r,g,b,a=hexadecimal_to_rgba_percent(graph_color)
      cairo_context:set_source_rgba(r,g,b,a)
      cairo_context:set_line_width(1)
      if value <= 1 and value > limit_2 then
        ratio = (value - limit_2) / (1 - limit_2)
        cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0  , PI * 0.5)
        cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
        cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * (1+(0.5* ratio)) )
        cairo_context:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*(2 -(0.5* ratio)), PI *2)
        cairo_context:close_path()
        cairo_context:stroke()
      elseif value <= limit_2 and value > limit_1 then
        ratio = value  / limit_2
        cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0  , PI * 0.5)
        cairo_context:arc(x + radius*rounded_size,height - radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cairo_context:line_to(x,y + height - (height * ratio*limit_2) )
      cairo_context:line_to(width,y+ height - (height * ratio*limit_2) )
      cairo_context:close_path()
      cairo_context:stroke()
      elseif value <= limit_1 and value > 0 then
        ratio = value  / limit_1
        cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*(0.5-( 0.5*ratio))  , PI * 0.5)
        cairo_context:arc(x + radius*rounded_size,height - radius*rounded_size, radius*rounded_size,PI*0.5, PI *(0.5+ (0.5*ratio)))
        cairo_context:close_path()
        cairo_context:stroke()
      end
    end
  end
end
function generate_rounded_rectangle_with_text_in_image(text, padding, background_color, text_color, font_size, rounded_size)
  local data={}
  local padding = padding or 2
  --find the height and width of the image:
  local cairo_surface=cairo.image_surface_create("argb32",20, 20)
  local cr = cairo.context_create(cairo_surface)
  local ext = cr:text_extents(text)
  data.height = font_size + 2* padding
  data.width = ext.width +ext.x_bearing*2 + 2*padding
  
  --recreate the cairo context with good width and height:
  cairo_surface= nil
  cr=nil
  cairo_surface=cairo.image_surface_create("argb32",data.width, data.height)
  cr = cairo.context_create(cairo_surface)

  --draw the background
  draw_rounded_corners_rectangle(cr,0,0,data.width, data.height, background_color, rounded_size)
  
  --draw the text
  cr:move_to(padding, data.height - padding)
  r,g,b,a=hexadecimal_to_rgba_percent(text_color)
  cr:set_source_rgba(r,g,b,a)
  cr:show_text(text)
  
  data.raw_image = cairo_surface:get_data()
  return data
end
function hash_remove(hash,key)
  local element = hash[key]
  hash[key] = nil
  return element
end


local function is_leap_year(year)
  return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

days_in_m = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
function get_days_in_month(month, year)
  if month == 2 and is_leap_year(year) then
    return 29
  else
    return days_in_m[month]
  end
end
