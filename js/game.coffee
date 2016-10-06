# This holds all the game logic **NO DRAWING** just the logix
window.init_game = (w, h) ->
	# initialize and return game objects	
	# objs locations are in pixels, where the top left is 0,0
	# sprite keys are unique
	#
	#
	n = 1
	game_objs = {
		sprites:
			dante: init_obj(w / 2, h / 2, 30, "black", "player")
		forces:[	# force functions accept distance and the object the force is acting on
			[ "runner", "runner", mob_repulsion ],
			[ "runner", "chaser", mob_repulsion ],
			[ "chaser", "runner", mob_repulsion ],
			[ "chaser", "chaser", mob_repulsion ],
			[ "runner", "player", runner_repulsion ]
			[ "chaser", "player", chaser_attraction ]
			[ "runner", "chaser", chaser_attraction ]
		]

		start: get_time()
		w: w
		h: h
		mouseX: w / 2
		mouseY: h / 2
		friction: 0.95
		score:0
		t:0  # update count
		hit_ctr: 0 # hit ctr
		n_run: n # remaining runners
		max_run: n  # max runners
	}
	init_mobs(game_objs, 3, 'rand', 'chaser')
	init_mobs(game_objs, game_objs.n_run, 'rand', 'runner')
	game_objs

# FORCES
# go: game_objs
# d: distance
# TODO randomize force params for every game
ep = 0.0000001 #epsilon, a small number
mob_repulsion = (go,d) -> 1 * Math.pow(1 / (d+ep), 1/2)*0.4
#runner_repulsion = (go,d) -> 1 * Math.pow(1 / (d/size(go)*0.5+ep), 1.2)*0.001
runner_repulsion = (go,d) -> 0.6
chaser_attraction = (go,d) -> -0.3

# size of the screen diagonally
size = (go) -> point_distance(0,0,go.w,go.w)
	
window.update = (game_objs) ->
	game_objs.t += 1
	game_objs.hit_ctr--
	console.log game_objs.hit_ctr
	detect_end game_objs
	apply_forces game_objs
	apply_friction game_objs
	move_dante game_objs
	move_sprites game_objs
	detect_hits game_objs
	#move_chasers game_objs
	#move_runners game_objs

detect_end = (go) ->
	test_pairs = get_pairs(go, 'runner','chaser')
	if not go.n_run
		go.sprites = {
			dante: init_obj(go.w / 2, go.h / 2, 30, "black", "player")
		}
		go.max_run = Math.ceil(go.max_run*1.18)
		go.n_run = go.max_run
		init_mobs(go, 3, 'rand', 'chaser')
		init_mobs(go, go.n_run, 'rand', 'runner')
		init_graphics( go )
	
init_mobs = (go, n, m, t ) ->
	#m: mode {'rand',}
	# t: type {'runner','chaser'
	
	c = if (t == 'runner') then 'blue' else 'red'

	for i in [1..n]
		if m == 'rand'
			[cx,cy] = [go.w*Math.random(), go.h * Math.random()]
			r = Math.random()*40 + 5
		else console.log 'no mode set'
		go.sprites[t+'_'+i] = init_obj(cx,cy, r, c, t)

detect_hits = (go) ->
	sprites = go.sprites
	p = go.sprites.dante
	for name of sprites
		sprite = sprites[name]
		[x1,y1,x2,y2] = [sprite.cx,sprite.cy, p.cx, p.cy]
		d = point_distance(x1,y1,x2,y2)
		if d < (sprite.r/2+p.r/2) and go.hit_ctr <= 0 and name != 'dante'
			hit(go, sprite)

hit = (go,sprite) ->
	go.hit_ctr = 1
	go.hit_img = sprite.img

	if sprite.type == 'runner'
		sprite.type = 'chaser'
		sprite.img = 'red'
		go.n_run--
		go.sprites.dante.r += 5
		go.score += 5

	if sprite.type == 'chaser'
		p = go.sprites.dante
		p.r-- if p.r > 5
		go.score--



zero_forces = (game_objs) ->
	for name of game_objs['sprites']
		game_objs['sprites'][name]['dvx'] = 0
		game_objs['sprites'][name]['dvy'] = 0

get_pairs = (game_objs, from_node, to_node) ->
	types = get_types( game_objs )
	if from_node in types
		from_nodes = get_sprite_group(game_objs, from_node)
	else from_nodes = [game_objs['sprites'][from_node]]
	
	if to_node in types
		to_nodes = get_sprite_group(game_objs, to_node)
	else to_nodes = [game_objs['sprites'][from_node]]

	pairs = []
	for tn in to_nodes
		for fn in from_nodes
			if tn isnt fn
				pairs.push [fn,tn]
	pairs

apply_force = (game_objs, pair, force) ->
	v1 = pair[0]
	v2 = pair[1]
	d = point_distance(v1.cx,v1.cy, v2.cx,v2.cy)
	dx = v1.cx - v2.cx
	dy = v1.cy - v2.cy
	d += 0.0000001
	f = force(game_objs,d)
	v1.dvx += dx/d * f
	v1.dvy += dy/d * f

apply_forces = (game_objs) ->
	# apply forces to corresponding sprites
	# apply friction to all sprites    
	
	zero_forces game_objs
	forces = game_objs['forces']
	for f in forces
		pairs = get_pairs(game_objs,f[0],f[1])
		for pair in pairs
			apply_force(game_objs, pair, f[2]) if pair[0]? and pair[1]?

apply_friction = (go) ->
	sprites = go['sprites']
	for name of sprites
		sprite = sprites[name]
		sprite.vx *= go.friction
		sprite.vy *= go.friction

get_types = (game_objs) ->
	types = []
	for sprite of game_objs["sprites"]
		t = game_objs["sprites"][sprite]["type"]
		types.push t unless types.indexOf(t) is 0
	types

get_sprite_group = (game_objs, group_type) ->
	group = []
	for name of game_objs["sprites"]
		sprite = game_objs["sprites"][name]
		if sprite["type"] == group_type
			group.push sprite
	group

get_time = ->
	d = new Date()
	d.getTime()

init_obj = (cx, cy, r, img, type) ->
  cx: cx
  cy: cy
  r: r
  img: img
  type: type
  dvx: 0 	# delta velocity x
  dvy: 0
  vx: 0 	# velocity x
  vy: 0

move_dante = (game_objs) ->
  dante = game_objs["sprites"]["dante"]
  dante["cx"] = game_objs["mouseX"]
  dante["cy"] = game_objs["mouseY"]

move_sprites = (game_objs) ->
	sprites = game_objs['sprites']
	for name of sprites
		sprite = sprites[name]
		sprite['vx'] += sprite['dvx']
		sprite['vy'] += sprite['dvy']
		sprite['cx'] += sprite['vx']
		sprite['cy'] += sprite['vy']
		sprite.dvx = 0
		sprite.dvy = 0

