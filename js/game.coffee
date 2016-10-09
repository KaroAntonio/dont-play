# This holds all the game logic **NO DRAWING** just the logix
window.init_game = (w, h) ->
	# initialize and return game objects	
	# objs locations are in pixels, where the top left is 0,0
	# sprite keys are unique
	#
	#
	n = 1
	size = 30
	# game objects
	go =
		sprites: init_sprites(w,h,size)
		dead_sprites: {}
		forces: init_forces()
		colors: init_colors()
		start: get_time()
		w: w
		h: h
		mouseX: w / 2
		mouseY: h / 2
		friction: 0.8
		score:0
		t:0  # update count
		hit_ctr: 0 # hit ctr
		n_run: n # remaining runners
		max_run: n  # max runners
		n_mobs: 0
		init_r: size
		max_r: size*2
		min_r: 5
		max_v: 20
		max_d: 4*w
		paused: true
	
	init_listeners go
	init_mob_groups go
	go

init_forces = (go) ->
	# force functions accept distance and the object the force is acting on
	[
			[ "runner", "runner", run_run ]
			[ "runner", "chaser", mob_mob ]
			[ "chaser", "runner", mob_mob ]
			[ "chaser", "chaser", mob_mob ]
			[ "runner", "chaser", run_cha ]
			[ "runner", "dante", run_pla ]
			[ "chaser", "dante", cha_pla ]
			[ "chaser", "repulsor", mob_rep ]
			[ "runner", "repulsor", run_pla ]
			[ "runner", "attractor", mob_att ]
			[ "chaser", "attractor", mob_att ]
			[ "chaser", "seed", cha_pla ]
			[ "runner", "seed", cha_pla ]
	]
	
# FORCES
# go: go
# d: distance
# TODO randomize force params for every game
ep = 0.0000001 #epsilon, a small number
mob_mob = (go,d) -> 1 * Math.pow(1 / (d+ep), 1/2)*0.6
run_pla = (go,d) ->
	if d < go.max_d
		f=(0.6+Math.pow(go.sprites.dante.r/(Math.pow(go.max_r/2,1)),6))
	else
		f = 0
	f

run_cha = (go,d) -> -0.8
run_run = (go,d) -> mob_mob(go,d)*5
cha_pla = (go,d) -> -0.9
mob_rep = (go,d) -> Math.pow(1 / (d/10+ep), 1/2)*0.8
mob_att = (go,d) -> -0.3

init_mob_groups = (go) ->
	init_mobs(go, 3, 'rand', 'chaser')
	init_mobs(go, go.n_run, 'rand', 'runner')

init_colors = () ->
	chaser: get_random_color()
	runner: get_random_color()
	repulsor: get_random_color()
	attractor: get_random_color()
	seed: get_random_color()

init_listeners = (go) ->
	# mouse listener
	$(window).mousemove (e) ->
        go['mouseX'] = e.clientX
        go['mouseY'] = e.clientY

	# keyboard listener
	handler = (e) ->
		console.log e.keyCode
		if not go.paused
			key_map =
				32:'repulsor'     	# space
				115:'repulsor'   	# s
				100:'attractor'    	# d 
				102:'chaser'      	# f
				97:'seed'    		# a
		
			if e.keyCode of key_map
				spawn_mob(go, key_map[e.keyCode])
			
			if e.keyCode in [104,112]
				go.paused = true
		else
			go.paused = false

	$(document).keypress(handler)

init_mobs = (go, n, m, t ) ->
	#m: mode {'rand',}
	# t: type {'runner','chaser'
	c = go.colors[t]

	for i in [1..n]
		if m == 'rand'
			[cx,cy] = [go.w*Math.random(), go.h * Math.random()]
			r = Math.random()*go.max_r + 5
		else console.log 'no mode set'
		name = t+'_'+i
		go.sprites[name] = init_sprite(name,cx,cy, r, c, t)

init_sprites = (w,h,s) ->
	dante: init_sprite('dante', w / 2, h / 2, s, "black", "player")
	hit: init_sprite('hit', w / 2, h / 2, s, "transparent", "hit")

# size of the screen diagonally
size = (go) -> point_distance(0,0,go.w,go.w)
	
window.update = (go) ->
	if not go.paused
		go.t += 1
		go.hit_ctr--
		
		if not go.n_run
			restart go

		update_sprites go
		apply_forces go
		apply_friction go
		move_dante go
		move_sprites go
		detect_hits go

update_sprites = (go) ->
	sprites = go.sprites
	for name of sprites
		sprite = sprites[name]
		if sprite.type in ['repulsor','attractor','seed']
			sprite.r -= 0.1
		if sprite.r <= 0
			delete sprites[name]
			if sprite.type == 'runner'
				go.n_run--

spawn_mob = (go, t ) ->
	p = go.sprites.dante

	# mob params : [radius, color, spawn_penalty]
	mp =
		chaser:[Math.random()*go.max_r + 5,go.colors[t],0]
		repulsor:[go.max_r * 2,go.colors[t],5]
		attractor:[go.max_r * 2,go.colors[t],5]
		hit:[1,go.hit_img,0]
		seed:[go.sprites.dante.r,go.colors[t],p.r-5]

	r = mp[t][0]
	if go.sprites.dante.r <= go.min_r
		r *= 0.2
	else go.sprites.dante.r -= mp[t][2]

	name = t+'_'+go.t
	if r > 5
		go.sprites[name] = init_sprite(name,p.cx,p.cy, r, mp[t][1], t)
	
restart = (go) ->
	# clean up current level
	for name of go.sprites
		go.dead_sprites[name+'_'+go.t] = go.sprites[name]

	go.sprites = init_sprites(go.w, go.h, go.init_r)
	go.colors = init_colors()
	go.forces = init_forces()
	go.max_run = Math.ceil(go.max_run*1.18)
	go.n_run = go.max_run
	init_mob_groups go
	init_graphics go

detect_hits = (go) ->
	targets = get_sprite_group(go,'seed')
	targets.push go.sprites.dante
	for name of go.sprites
		for t in targets
			s = go.sprites[name]
			d = point_distance(s.cx,s.cy, t.cx, t.cy)
			is_hit = d < (s.r/2+t.r/2)
			is_valid = s.type in ['chaser','runner']
			not_player = name != 'dante'
			# if a chaser or a runner hits a seed
			hit_seed = t.type == 'seed' and (is_valid or not not_player)
			hit_player = t.name == 'dante' and is_valid and not_player
			if is_hit and (hit_seed or hit_player)
				hit(go, s, t)

hit = (go,sprite, target) ->
	if target.name == 'dante'
		if go.hit_ctr <= 0
			go.hit_img = sprite.img
			go.hit_ctr = 5

		if sprite.type == 'runner'
			sprite.type = 'chaser'
			sprite.img = go.colors.chaser
			go.n_run--
			target.r += 5
			go.score += 5

		if sprite.type == 'chaser'
			p = target 
			p.r-- if p.r > go.min_r
			sprite.r--
			go.score--

	if target.type == 'seed'
		sprite.r++

zero_velocities = (go) ->
	for name of go['sprites']
		go['sprites'][name]['dvx'] = 0
		go['sprites'][name]['dvy'] = 0

get_pairs = (go, from_node, to_node) ->
	types = get_types( go )
	if from_node in types
		from_nodes = get_sprite_group(go, from_node)
	else from_nodes = [go['sprites'][from_node]]
	
	if to_node in types
		to_nodes = get_sprite_group(go, to_node)
	else to_nodes = [go['sprites'][to_node]]

	pairs = []
	for tn in to_nodes
		for fn in from_nodes
			if tn isnt fn
				pairs.push [fn,tn]
	pairs

apply_force = (go, pair, force) ->
	v1 = pair[0]
	v2 = pair[1]
	d = point_distance(v1.cx,v1.cy, v2.cx,v2.cy)
	dx = v1.cx - v2.cx
	dy = v1.cy - v2.cy
	d += 0.0000001
	f = force(go,d)
	v1.dvx += dx/d * f
	v1.dvy += dy/d * f

apply_forces = (go) ->
	# apply forces to corresponding sprites
	# apply friction to all sprites    
	
	zero_velocities go
	forces = go['forces']
	
	for f in forces
		pairs = get_pairs(go,f[0],f[1])
		for pair in pairs
			apply_force(go, pair, f[2]) if pair[0]? and pair[1]?

apply_friction = (go) ->
	sprites = go['sprites']
	for name of sprites
		sprite = sprites[name]
		sprite.vx *= go.friction
		sprite.vy *= go.friction

get_types = (go) ->
	types = []
	for sprite of go["sprites"]
		t = go["sprites"][sprite]["type"]
		types.push t unless types.indexOf(t) is 0
	types

get_sprite_group = (go, group_type) ->
	group = []
	for name of go["sprites"]
		sprite = go["sprites"][name]
		if sprite["type"] == group_type
			group.push sprite
	group

get_time = ->
	d = new Date()
	d.getTime()

init_sprite = (name, cx, cy, r, img, type) ->
	name: name
	cx: cx
	cy: cy
	r: r
	img: img
	type: type
	dvx: 0 	# delta velocity x
	dvy: 0
	vx: 0 	# velocity x
	vy: 0

move_dante = (go) ->
  dante = go["sprites"]["dante"]
  dante["cx"] = go["mouseX"]
  dante["cy"] = go["mouseY"]

move_sprites = (go) ->
	sprites = go['sprites']
	for name of sprites
		sprite = sprites[name]
		sprite['vx'] += sprite['dvx']
		sprite['vy'] += sprite['dvy']
		sprite['cx'] += restrict_v(go,sprite['vx'])
		sprite['cy'] += restrict_v(go,sprite['vy'])
		sprite.dvx = 0
		sprite.dvy = 0

restrict_v = (go, v) ->
	if v > go.max_v and v > 0
		v = go.max_v
	if v < -go.max_v and v <= 0
		v = -go.max_v
	v

get_random_color = ->
	letters = '0123456789ABCDEF'
	color = '#'
	i = 0
	while i < 6
		color += letters[Math.floor(Math.random() * 16)]
		i++
	color
