window.init_graphics = (go) ->

	if not go.three?
		init_three go

	init_bg go
	init_score go
	init_info go
	init_msg go
	#init_sprite_divs go
	init_sprite_cubes go
	init_body go
	#fade_dead_sprites go
	fade_dead_cubes go

init_three = (go) ->
	three_div = $('<div>')
	three_div.css
		margin: 0
		position: 'fixed'
		zIndex: -2

	three_div.appendTo('body')

	camera = new THREE.PerspectiveCamera 90, window.innerWidth / window.innerHeight, 0.1, 10000
	renderer = new THREE.WebGLRenderer
		antialias: true
		alpha: true

	scene = new THREE.Scene()
	scene.background = new THREE.Color( 0xff0000 )

	camera.position.z = 300
	camera.lookAt new THREE.Vector3 0, 0, 0

	scene.add camera

	renderer.setSize window.innerWidth, window.innerHeight
	three_div.append renderer.domElement

	Light1 = new THREE.PointLight 0xffffff, 1
	Light1.position.x = 1500
	Light1.position.z = 4000
	scene.add Light1

	go['three'] =
		div:three_div
		camera:camera
		scene:scene
		renderer: renderer

init_color = (s) ->
	c = new THREE.MeshPhongMaterial
		color: s.img
		specular : s.img
		emissive : s.img
		shininess: 2
		transparent: true
		opacity: s.opacity
		shading: THREE.FlatShading
		
init_sprite_cube = (go,name) ->
	s = go["sprites"][name]

	r = go.max_r
	cube = new THREE.Mesh new THREE.BoxGeometry(r,r,10), init_color(s)

	go.three.scene.add cube

	s["cube"] = cube

init_sprite_cubes = (go) ->
	for name of go.sprites
		init_sprite_cube(go,name)

init_sprite_divs = (go) ->
	# init_sprite reps
	for name of go["sprites"]
		init_sprite_div(go,name)

init_body = (go) ->
	$('body').css
		fontFamily: 'monospace'
		position: 'fixed'
		cursor: 'none'

init_score = (go) ->
	if go.hud?
		go.hud.score.remove()

	score = $("<div>")
	score.appendTo 'body'
	score.css
		position: "fixed"
		height: 50
		width: 50
		left: 25
		top: go.h-50
		fontSize: 20

	go['hud'] =
		score: score

init_bg = (go) ->
	if go.bg?
		go.bg.remove()
	bg = $("<div>")
	bg.appendTo 'body'
	go.bg = bg
	bg.css
		position: "fixed"
		height: "100vh"
		width: "100vw"
		zIndex: -100

window.render = (go) ->
	render_background go
	#render_sprites go
	render_cubes go
	render_hud go
	render_info go
	render_msg go

	go.three.renderer.render go.three.scene, go.three.camera

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
	
		set_msg go

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
			MOUSE: move <br>\
			<br>\
				>> PRESS ANY KEY TO START <<<br>\
			'
set_msg = (go) ->
	i = Math.floor(Math.random() * go.msgs.length)
	go.msg.html go.msgs[i]

render_msg = (go) ->
	w1 = (Math.sin(go.t/50)+1)/2
	go.msg.css
		opacity: w1

	if go.msg.css('opacity') <= 0.01
		set_msg go

render_info = (go) ->
	if go.paused
		go.info.css
			zIndex: 1
	else
		go.info.css
			zIndex: -101

fade_dead_cubes = (go) ->
	for name of go.dead_sprites
		s = go.dead_sprites[name]
		if s.cube?
			s.cube.position.z -= 20
			s.cube.scale.z = 0.4
			s.opacity *= 0.7
			s.cube.material = init_color(s)

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

render_cubes = (go) ->
	for name of go["sprites"]
		s = go["sprites"][name]
		if not s.cube?
			init_sprite_cube(go,name)

		cube = s.cube
		if name == 'hit'
			s = go.sprites.dante
			
		cube.position.x = s.cx-go.w/2
		cube.position.y = -(s.cy-go.h/2)
		cube.material = init_color(s)

		cs = s.r/go.max_r
		if name is 'hit'
			if go.hit_ctr > 0
				cs = (s.r+20)/go.max_r
			else
				cs = 0.00001
		cube.scale.set(cs,cs,cs)

		if s.type in ['repulsor','attractor','seed']
			#what to do here
			cube.scale.z=1
			cube.position.z = -20

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

