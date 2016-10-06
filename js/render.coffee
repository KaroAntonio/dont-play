window.init_graphics = (game_objs) ->
  # probably only necessary if we're using html as the graphics

	for name of game_objs["sprites"]
		init_sprite_div(game_objs,name)

	if game_objs.hud?
		game_objs.hud.score.remove()

	score = $("<div>")
	score.css
		position: "fixed"
		height: 50
		width: 50
		left: 25
		top: game_objs.h-50
		fontSize: 20
		fontFamily: 'monospace'

	score.appendTo $('body')

	game_objs['hud'] = { score: score }

	$("body").css
		height: "100vh"
		width: "100vw"

window.render = (game_objs) ->
	render_background game_objs
	render_sprites game_objs
	render_hud game_objs

init_sprite_div = (go, name) ->
	sprite = game_objs["sprites"][name]
	new_div = $("<div>")
	new_div.css
		position: "fixed"
		height: sprite["r"]
		width: sprite["r"]
		fill: sprite["img"]

	$("body").append new_div
	sprite["div"] = new_div

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
	for name of game_objs["sprites"]
		s = game_objs["sprites"][name]
		if not s.div?
			init_sprite_div(game_objs,name)
		s["div"].css
			background: s["img"]
			fill: s["img"]
			left: s["cx"] - s["r"] / 2
			top: s["cy"] - s["r"] / 2
			height: s["r"]
			width: s["r"]
	
		if name == 'hit'
			p = game_objs.sprites.dante
			r = p.r+20
			s.div.css
				left: p.cx - r / 2
				top: p.cy - r / 2
				height: r
				width: r

			if game_objs.hit_ctr > 0
				s.div.css
					background: game_objs.hit_img

		if s.type in ['repulsor','attractor']
			s.div.css
				zIndex:-2

		if name == 'dante'
			s["div"].css


