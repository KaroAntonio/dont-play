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

	if game_objs.hud?
		game_objs.hud.score.remove()

	score = $("<div>")
	score.css
		position: "fixed"
		height: 50
		width: 50
		left: 25
		top:game_objs.h-50
		fontSize: 30
	score.appendTo $('body')

	game_objs['hud'] = { score: score }

	$("body").css
		height: "100vh"
		width: "100vw"

window.render = (game_objs) ->
  render_background game_objs
  render_sprites game_objs
  render_hud game_objs

render_background = (go) ->
	'''
	if go.hit_ctr > 0
		$('body').css
			background: go.hit_img
	else
		$('body').css
			background: '#fff'
	'''

render_hud = (go) ->
	go.hud.score.text(go.score)

render_sprites = (game_objs) ->
  for sprite of game_objs["sprites"]
    s = game_objs["sprites"][sprite]
    s["div"].css
      background: s["img"]
      fill: s["img"]
      left: s["cx"] - s["r"] / 2
      top: s["cy"] - s["r"] / 2
      height: s["r"]
      width: s["r"]


