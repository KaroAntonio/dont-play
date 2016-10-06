// Generated by CoffeeScript 1.11.1
(function() {
  var apply_force, apply_forces, apply_friction, chaser_attraction, ep, get_pairs, get_sprite_group, get_time, get_types, init_obj, mob_repulsion, move_chasers, move_dante, move_group, move_runners, move_sprites, runner_repulsion, size, zero_forces,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.init_game = function(w, h) {
    var game_objs;
    game_objs = {
      sprites: {
        pineapple: init_obj(w * 0.25, h / 2, 50, "red", 2, "chaser"),
        gourd: init_obj(w * 0.3, h / 2, 50, "red", 2, "chaser"),
        orange: init_obj(w * 0.4, h / 2, 50, "red", 2, "chaser"),
        pear: init_obj(w * 0.75, h / 2, 50, "red", 2, "chaser"),
        grape: init_obj(w * 0.75, h * 0.75, 50, "red", 2, "chaser"),
        apple: init_obj(w * 0.9, h * 0.75, 50, "red", 2, "chaser"),
        muffin: init_obj(w * 0.75, h / 2, 50, "blue", 2, "runner"),
        cupcake: init_obj(w * 0.25, h / 2, 50, "blue", 2, "runner"),
        scone: init_obj(w * 0.25, h * 0.25, 50, "blue", 2, "runner"),
        dante: init_obj(w / 2, h / 2, 50, "black", 10, "player")
      },
      forces: [["runner", "runner", mob_repulsion], ["runner", "chaser", mob_repulsion], ["chaser", "runner", mob_repulsion], ["chaser", "chaser", mob_repulsion], ["runner", "player", runner_repulsion], ["chaser", "player", chaser_attraction], ["runner", "chaser", chaser_attraction]],
      time: get_time(),
      w: w,
      h: h,
      mouseX: w / 2,
      mouseY: h / 2,
      friction: 0.95,
      t: 0
    };
    return game_objs;
  };

  ep = 0.0000001;

  mob_repulsion = function(go, d) {
    return 1 * Math.pow(1 / (d + ep), 1 / 2) * 0.4;
  };

  runner_repulsion = function(go, d) {
    return 0.55;
  };

  chaser_attraction = function(go, d) {
    return -0.3;
  };

  size = function(go) {
    return point_distance(0, 0, go.w, go.w);
  };

  window.update = function(game_objs) {
    game_objs.t += 1;
    apply_forces(game_objs);
    apply_friction(game_objs);
    move_dante(game_objs);
    return move_sprites(game_objs);
  };

  zero_forces = function(game_objs) {
    var name, results;
    results = [];
    for (name in game_objs['sprites']) {
      game_objs['sprites'][name]['dvx'] = 0;
      results.push(game_objs['sprites'][name]['dvy'] = 0);
    }
    return results;
  };

  get_pairs = function(game_objs, from_node, to_node) {
    var fn, from_nodes, i, j, len, len1, pairs, tn, to_nodes, types;
    types = get_types(game_objs);
    if (indexOf.call(types, from_node) >= 0) {
      from_nodes = get_sprite_group(game_objs, from_node);
    } else {
      from_nodes = [game_objs['sprites'][from_node]];
    }
    if (indexOf.call(types, to_node) >= 0) {
      to_nodes = get_sprite_group(game_objs, to_node);
    } else {
      to_nodes = [game_objs['sprites'][from_node]];
    }
    pairs = [];
    for (i = 0, len = to_nodes.length; i < len; i++) {
      tn = to_nodes[i];
      for (j = 0, len1 = from_nodes.length; j < len1; j++) {
        fn = from_nodes[j];
        if (tn !== fn) {
          pairs.push([fn, tn]);
        }
      }
    }
    return pairs;
  };

  apply_force = function(game_objs, pair, force) {
    var d, dx, dy, f, v1, v2;
    v1 = pair[0];
    v2 = pair[1];
    d = point_distance(v1.cx, v1.cy, v2.cx, v2.cy);
    dx = v1.cx - v2.cx;
    dy = v1.cy - v2.cy;
    d += 0.0000001;
    f = force(game_objs, d);
    v1.dvx += dx / d * f;
    return v1.dvy += dy / d * f;
  };

  apply_forces = function(game_objs) {
    var f, forces, i, len, pair, pairs, results;
    zero_forces(game_objs);
    forces = game_objs['forces'];
    results = [];
    for (i = 0, len = forces.length; i < len; i++) {
      f = forces[i];
      pairs = get_pairs(game_objs, f[0], f[1]);
      results.push((function() {
        var j, len1, results1;
        results1 = [];
        for (j = 0, len1 = pairs.length; j < len1; j++) {
          pair = pairs[j];
          results1.push(apply_force(game_objs, pair, f[2]));
        }
        return results1;
      })());
    }
    return results;
  };

  apply_friction = function(go) {
    var name, results, sprite, sprites;
    sprites = go['sprites'];
    results = [];
    for (name in sprites) {
      sprite = sprites[name];
      sprite.vx *= go.friction;
      results.push(sprite.vy *= go.friction);
    }
    return results;
  };

  get_types = function(game_objs) {
    var sprite, t, types;
    types = [];
    for (sprite in game_objs["sprites"]) {
      t = game_objs["sprites"][sprite]["type"];
      if (types.indexOf(t) !== 0) {
        types.push(t);
      }
    }
    return types;
  };

  get_sprite_group = function(game_objs, group_type) {
    var group, name, sprite;
    group = [];
    for (name in game_objs["sprites"]) {
      sprite = game_objs["sprites"][name];
      if (sprite["type"] === group_type) {
        group.push(sprite);
      }
    }
    return group;
  };

  get_time = function() {
    var d;
    d = new Date();
    return d.getTime();
  };

  init_obj = function(cx, cy, r, img, s, type) {
    return {
      cx: cx,
      cy: cy,
      r: r,
      img: img,
      s: s,
      type: type,
      dvx: 0,
      dvy: 0,
      vx: 0,
      vy: 0
    };
  };

  move_dante = function(game_objs) {
    var dante;
    dante = game_objs["sprites"]["dante"];
    dante["cx"] = game_objs["mouseX"];
    return dante["cy"] = game_objs["mouseY"];
  };

  move_sprites = function(game_objs) {
    var name, results, sprite, sprites;
    sprites = game_objs['sprites'];
    results = [];
    for (name in sprites) {
      sprite = sprites[name];
      sprite['vx'] += sprite['dvx'];
      sprite['vy'] += sprite['dvy'];
      sprite['cx'] += sprite['vx'];
      sprite['cy'] += sprite['vy'];
      sprite.dvx = 0;
      results.push(sprite.dvy = 0);
    }
    return results;
  };

  move_group = function(game_objs, group_name, dv) {
    var dante, dist, dx, dy, group, member, name, results;
    dante = game_objs["sprites"]["dante"];
    group = get_sprite_group(game_objs, group_name);
    results = [];
    for (name in group) {
      member = group[name];
      dx = dv * (dante["cx"] - member["cx"]);
      dy = dv * (dante["cy"] - member["cy"]);
      dist = point_distance(member["cx"], member["cy"], dante["cx"], dante["cy"]);
      member["cx"] += (dx / dist) * member["s"];
      results.push(member["cy"] += (dy / dist) * member["s"]);
    }
    return results;
  };

  move_chasers = function(game_objs) {
    return move_group(game_objs, "chaser", +1);
  };

  move_runners = function(game_objs) {
    return move_group(game_objs, "runner", -1);
  };

}).call(this);