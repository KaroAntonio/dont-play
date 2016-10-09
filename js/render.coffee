window.init_graphics = (go) ->
	# probably only necessary if we're using html as the graphics

	for name of go["sprites"]
		init_sprite_div(go,name)

	if go.hud?
		go.hud.score.remove()

	$('body').css
		fontFamily: 'monospace'
	
	score = $("<div>")
	score.css
		position: "fixed"
		height: 50
		width: 50
		left: 25
		top: go.h-50
		fontSize: 20

	score.appendTo 'body'

	go['hud'] = { score: score }

	# BACKGROUND
	$('body').css
		position: 'fixed'

	n_bg_imgs = 2
	
	if go.bg?
		go.bg.remove()
	i = Math.floor(Math.random() * n_bg_imgs)
	bg = $("<div>")
	bg.appendTo 'body'
	go.bg = bg
	bg.css
		position: "fixed"
		height: "100vh"
		width: "100vw"
		zIndex: -100

	fade_dead_sprites go
	init_info go
	init_msg go

window.render = (go) ->
	render_background go
	render_sprites go
	render_hud go
	render_info go
	render_msg go

init_msg = (go) ->
	if not go.msg?
		msg = $('<div>')
		go['msg'] = msg
		msg.appendTo('body')
		msg.css
			position: 'fixed'
			top: go.h*0.4
			width: go.w
			zIndex:-2
			textAlign: 'center'
			fontSize: 28

		msg.html 'go home'

init_info = (go) ->
	if not go.info?
		info = $('<div>')
		go['info'] = info
		info.appendTo('body')
		info.css
			position: "absolute"
			overflow: 'scroll'
			height: go.h*0.6
			width: go.w*0.6
			padding: 15
			marginTop: go.h*0.2
			marginLeft: go.w*0.2
			marginRight: go.w*0.2
			marginBottom: go.w*0.2
			fontSize: 25
			background: '#fff'

		info.html '\
			DANTE: DONT PLAY THIS  <br>\
			Chase the ones that run away from you, <br>\
			run from the ones that chase you, simple ;) <br>\ 
			The numbers on the bottom left work like: <br>\ 
			score // life // runners left <br>\
			<br>\
			A: spawn a seed, warning: super growey  <br>\
			S: spaw a repulsor, pushes things away <br>\
			D: spa an attractor, like a mini black-hole <br>\
			F: sp a chaser... he gonna get u <br>\
			H: get back here 	<br>\
			<br>\
				>> PRESS ANY KEY TO START <<<br>\
			'

render_msg = (go) ->
	w1 = (Math.sin(go.t/100)+1)/2
	go.msg.css
		opacity: w1

	if go.msg.css('opacity') <= 0.01
		go.msg.html 'keep going'

render_info = (go) ->
	if go.paused
		go.info.css
			zIndex: 1
	else
		go.info.css
			zIndex: -101


fade_dead_sprites = (go) ->
	for name of go.dead_sprites
		s = go.dead_sprites[name]
		if s.div?
			s.div.css
				opacity: s.div.css('opacity')*0.6
				zIndex: -3

init_sprite_div = (go, name) ->
	sprite = go["sprites"][name]
	new_div = $("<div>")
	new_div.css
		position: "fixed"
		height: sprite["r"]
		width: sprite["r"]
		fill: sprite["img"]
		opacity: 1

	$("body").append new_div
	sprite["div"] = new_div

render_background = (go) ->
	'''
	'''
	w1 = (Math.sin(go.t/1000)+1)/2
	w2 = (Math.cos(go.t/5000)+1)/2
	c = w1*w2*240+120
	go.bg.css
		background: 'hsl('+c+',100%,97%)'

render_hud = (go) ->
	go.hud.score.text(go.score + '//'+ go.sprites.dante.r + '//' + go.n_run)

render_sprites = (go) ->
	for name of go["sprites"]
		s = go["sprites"][name]
		if not s.div?
			init_sprite_div(go,name)
		s["div"].css
			background: s["img"]
			fill: s["img"]
			left: s["cx"] - s["r"] / 2
			top: s["cy"] - s["r"] / 2
			height: s["r"]
			width: s["r"]
	
		if name == 'hit'
			p = go.sprites.dante
			r = p.r+20
			s.div.css
				left: p.cx - r / 2
				top: p.cy - r / 2
				height: r
				width: r

			if go.hit_ctr > 0
				s.div.css
					background: go.hit_img

		if s.type in ['repulsor','attractor','seed']
			s.div.css
				zIndex:-1

