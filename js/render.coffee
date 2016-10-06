window.init_graphics = (game_objs) ->
  # probably only necessary if we're using html as the graphics

  for sprite of game_objs["sprites"]
    sdata = game_objs["sprites"][sprite]
    new_div = $("<div>")
    new_div.css
      position: "fixed"
      height: sdata["r"]
      width: sdata["r"]
      fill: sdata["img"]

    $("body").append new_div
    sdata["div"] = new_div
  $("body").css
    height: "100vh"
    width: "100vw"

window.render = (game_objs) ->
  render_background()
  render_sprites game_objs

render_background = ->
	
render_sprites = (game_objs) ->
  for sprite of game_objs["sprites"]
    s = game_objs["sprites"][sprite]
    s["div"].css
      background: s["img"]
      left: s["cx"] - s["r"] / 2
      top: s["cy"] - s["r"] / 2


