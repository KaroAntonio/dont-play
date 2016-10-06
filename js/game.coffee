# This holds all the game logic **NO DRAWING** just the logix
window.init_game = (w, h) ->
	# initialize and return game objects	
	# objs locations are in pixels, where the top left is 0,0
	# sprite keys are unique
	#
	game_objs = {
		sprites:
			pineapple: init_obj(w * 0.25, h / 2, 50, "red", 2, "chaser")
			gourd: init_obj(w * 0.3, h / 2, 50, "red", 2, "chaser")
			orange: init_obj(w * 0.4, h / 2, 50, "red", 2, "chaser")
			pear: init_obj(w * 0.75, h / 2, 50, "red", 2, "chaser")
			grape: init_obj(w * 0.75, h *0.75, 50, "red", 2, "chaser")
			apple: init_obj(w * 0.9, h *0.75, 50, "red", 2, "chaser")
			muffin: init_obj(w * 0.75, h / 2, 50, "blue", 2, "runner")
			cupcake: init_obj( w * 0.25, h / 2, 50, "blue", 2, "runner")
			scone: init_obj( w * 0.25, h *0.25, 50, "blue", 2, "runner")
			dante: init_obj(w / 2, h / 2, 50, "black", 10, "player")
		forces:[	# force functions accept distance and the object the force is acting on
			[ "runner", "runner", mob_repulsion ],
			[ "runner", "chaser", mob_repulsion ],
			[ "chaser", "runner", mob_repulsion ],
			[ "chaser", "chaser", mob_repulsion ],
			[ "runner", "player", runner_repulsion ]
			[ "chaser", "player", chaser_attraction ]
			[ "runner", "chaser", chaser_attraction ]
		]

		time: get_time()
		w: w
		h: h
		mouseX: w / 2
		mouseY: h / 2
		friction: 0.95
		t:0  # update count
	}
	game_objs

# FORCES
# go: game_objs
# d: distance
ep = 0.0000001 #epsilon, a small number
mob_repulsion = (go,d) -> 1 * Math.pow(1 / (d+ep), 1/2)*0.4
#runner_repulsion = (go,d) -> 1 * Math.pow(1 / (d/size(go)*0.5+ep), 1.2)*0.001
runner_repulsion = (go,d) -> 0.55
chaser_attraction = (go,d) -> -0.3

# size of the screen diagonally
size = (go) -> point_distance(0,0,go.w,go.w)
	
window.update = (game_objs) ->
	game_objs.t += 1
	apply_forces game_objs
	apply_friction game_objs
	move_dante game_objs
	move_sprites game_objs
	#move_chasers game_objs
	#move_runners game_objs

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
			apply_force(game_objs, pair, f[2])

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

init_obj = (cx, cy, r, img, s, type) ->
  cx: cx
  cy: cy
  r: r
  img: img
  s: s # speed
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

move_group = (game_objs, group_name, dv) ->
  # move members of group towards or away from dante	
  dante = game_objs["sprites"]["dante"]
  group = get_sprite_group(game_objs, group_name)
  for name of group
    member = group[name]
    dx = dv * (dante["cx"] - member["cx"])
    dy = dv * (dante["cy"] - member["cy"])
    dist = point_distance(member["cx"], member["cy"], dante["cx"], dante["cy"])
    member["cx"] += (dx / dist) * member["s"]
    member["cy"] += (dy / dist) * member["s"]

move_chasers = (game_objs) ->
  # chasers move towards dante
  move_group game_objs, "chaser", +1

move_runners = (game_objs) ->
  # chasers move towards dante
  move_group game_objs, "runner", -1
