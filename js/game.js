// Generated by CoffeeScript 1.11.1
(function() {
  var add_force_pairs, apply_force, apply_forces, apply_friction, build_fields, build_force_pairs, cha_pla, del_force_pairs, detect_hits, ep, get_pairs, get_random_color, get_sprite_group, get_time, get_types, hit, init_colors, init_forces, init_listeners, init_mob_groups, init_mobs, init_sprite, init_sprites, mob_att, mob_mob, mob_rep, move_dante, move_sprites, restart, restrict_v, run_cha, run_pla, run_run, size, spawn_mob, update_sprites, zero_velocities,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.init_game = function(w, h) {
    var go, n, size;
    n = 15;
    size = 30;
    go = {
      sprites: init_sprites(w, h, size),
      dead_sprites: {},
      forces: init_forces(),
      colors: init_colors(),
      start: get_time(),
      w: w,
      h: h,
      mouseX: w / 2,
      mouseY: h / 2,
      friction: 0.8,
      score: 0,
      t: 0,
      hit_ctr: 0,
      n_run: n,
      max_run: n,
      n_mobs: 0,
      init_r: size,
      max_r: size * 2,
      min_r: 5,
      max_v: 20,
      max_d: w * 2,
      paused: true
    };
    init_listeners(go);
    init_mob_groups(go);
    build_fields(go);
    build_force_pairs(go);
    return go;
  };

  init_forces = function(go) {
    return [["runner", "runner", run_run], ["chaser", "runner", mob_mob], ["chaser", "chaser", mob_mob], ["runner", "chaser", run_cha], ["runner", "player", run_pla], ["chaser", "player", cha_pla], ["chaser", "repulsor", mob_rep], ["runner", "repulsor", run_pla], ["runner", "attractor", mob_att], ["chaser", "attractor", mob_att], ["chaser", "seed", cha_pla], ["runner", "seed", cha_pla]];
  };

  ep = 0.0000001;

  mob_mob = function(go, d) {
    return 1 * Math.pow(1 / (d + ep), 1 / 2) * 0.6;
  };

  run_pla = function(go, d) {
    var f;
    if (d < go.max_d) {
      return f = 0.6 + Math.pow(go.sprites.dante.r / (Math.pow(go.max_r / 2, 1)), 6);
    } else {
      return f = -0.3;
    }
  };

  run_cha = function(go, d) {
    return -0.8;
  };

  run_run = function(go, d) {
    return mob_mob(go, d) * 5;
  };

  cha_pla = function(go, d) {
    return -0.9;
  };

  mob_rep = function(go, d) {
    return Math.pow(1 / (d / 10 + ep), 1 / 2) * 0.8;
  };

  mob_att = function(go, d) {
    return -0.3;
  };

  init_mob_groups = function(go) {
    init_mobs(go, 3, 'rand', 'chaser');
    return init_mobs(go, go.n_run, 'rand', 'runner');
  };

  init_colors = function() {
    return {
      chaser: get_random_color(),
      runner: get_random_color(),
      repulsor: get_random_color(),
      attractor: get_random_color(),
      seed: get_random_color()
    };
  };

  init_listeners = function(go) {
    var handler;
    $(window).mousemove(function(e) {
      go['mouseX'] = e.clientX;
      return go['mouseY'] = e.clientY;
    });
    handler = function(e) {
      var key_map, ref;
      if (!go.paused) {
        key_map = {
          32: 'repulsor',
          115: 'repulsor',
          100: 'attractor',
          102: 'chaser',
          97: 'seed'
        };
        if (e.keyCode in key_map) {
          spawn_mob(go, key_map[e.keyCode]);
        }
        if ((ref = e.keyCode) === 104 || ref === 112) {
          return go.paused = true;
        }
      } else {
        return go.paused = false;
      }
    };
    return $(document).keypress(handler);
  };

  init_mobs = function(go, n, m, t) {
    var c, cx, cy, i, j, name, r, ref, ref1, results;
    c = go.colors[t];
    results = [];
    for (i = j = 1, ref = n; 1 <= ref ? j <= ref : j >= ref; i = 1 <= ref ? ++j : --j) {
      if (m === 'rand') {
        ref1 = [go.w * Math.random(), go.h * Math.random()], cx = ref1[0], cy = ref1[1];
        r = Math.random() * go.max_r + 5;
      } else {
        console.log('no mode set');
      }
      name = t + '_' + i;
      results.push(go.sprites[name] = init_sprite(name, cx, cy, r, c, t));
    }
    return results;
  };

  init_sprites = function(w, h, s) {
    return {
      dante: init_sprite('dante', w / 2, h / 2, s, "black", "player"),
      hit: init_sprite('hit', w / 2, h / 2, s, "transparent", "hit")
    };
  };

  size = function(go) {
    return point_distance(0, 0, go.w, go.w);
  };

  window.update = function(go) {
    if (!go.paused) {
      go.t += 1;
      go.hit_ctr--;
      if (!go.n_run) {
        restart(go);
      }
      update_sprites(go);
      apply_forces(go);
      apply_friction(go);
      move_dante(go);
      move_sprites(go);
      return detect_hits(go);
    }
  };

  build_fields = function(go) {
    var force, j, k, len, len1, ref, ref1, t, types;
    types = [];
    ref = go.forces;
    for (j = 0, len = ref.length; j < len; j++) {
      force = ref[j];
      ref1 = force.slice(0, 2);
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        t = ref1[k];
        if (indexOf.call(types, t) < 0) {
          types.push(t);
        }
      }
    }
    return go.types = types;
  };

  build_force_pairs = function(go) {
    var f, force_pairs, j, k, len, len1, pair, pairs, ref;
    force_pairs = [];
    ref = go.forces;
    for (j = 0, len = ref.length; j < len; j++) {
      f = ref[j];
      pairs = get_pairs(go, f[0], f[1]);
      for (k = 0, len1 = pairs.length; k < len1; k++) {
        pair = pairs[k];
        force_pairs.push([pair[0], pair[1], f[2]]);
      }
    }
    return go['force_pairs'] = force_pairs;
  };

  add_force_pairs = function(go, sprite) {
    var f, j, k, len, len1, pair, pairs, ref, results;
    ref = go.forces;
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      f = ref[j];
      if (f[0] === sprite.type) {
        pairs = get_pairs(go, sprite.name, f[1]);
        for (k = 0, len1 = pairs.length; k < len1; k++) {
          pair = pairs[k];
          go.force_pairs.push([pair[0], pair[1], f[2]]);
        }
      }
      if (f[1] === sprite.type) {
        pairs = get_pairs(go, f[0], sprite.name);
        results.push((function() {
          var l, len2, results1;
          results1 = [];
          for (l = 0, len2 = pairs.length; l < len2; l++) {
            pair = pairs[l];
            results1.push(go.force_pairs.push([pair[0], pair[1], f[2]]));
          }
          return results1;
        })());
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  del_force_pairs = function(go, sprite) {
    var e, fp, i, ref, results;
    i = go.force_pairs.length;
    results = [];
    while (i--) {
      fp = go.force_pairs[i];
      if (ref = sprite.name, indexOf.call((function() {
        var j, len, ref1, results1;
        ref1 = fp.slice(0, 2);
        results1 = [];
        for (j = 0, len = ref1.length; j < len; j++) {
          e = ref1[j];
          results1.push(e.name);
        }
        return results1;
      })(), ref) >= 0) {
        results.push(go.force_pairs.splice(i, 1));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  update_sprites = function(go) {
    var name, ref, results, sprite, sprites;
    sprites = go.sprites;
    results = [];
    for (name in sprites) {
      sprite = sprites[name];
      if ((ref = sprite.type) === 'repulsor' || ref === 'attractor' || ref === 'seed') {
        sprite.r -= 0.1;
      }
      if (sprite.r <= 0) {
        del_force_pairs(go, sprites[name]);
        delete sprites[name];
        if (sprite.type === 'runner') {
          results.push(go.n_run--);
        } else {
          results.push(void 0);
        }
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  spawn_mob = function(go, t) {
    var mp, name, p, r;
    p = go.sprites.dante;
    mp = {
      chaser: [Math.random() * go.max_r + 5, go.colors[t], 0],
      repulsor: [go.max_r * 2, go.colors[t], 5],
      attractor: [go.max_r * 2, go.colors[t], 5],
      hit: [1, go.hit_img, 0],
      seed: [go.sprites.dante.r, go.colors[t], p.r - 5]
    };
    r = mp[t][0];
    if (go.sprites.dante.r <= go.min_r) {
      r *= 0.2;
    } else {
      go.sprites.dante.r -= mp[t][2];
    }
    name = t + '_' + go.t;
    if (r > 5) {
      go.sprites[name] = init_sprite(name, p.cx, p.cy, r, mp[t][1], t);
      return add_force_pairs(go, go.sprites[name]);
    }
  };

  restart = function(go) {
    var name;
    for (name in go.sprites) {
      go.dead_sprites[name + '_' + go.t] = go.sprites[name];
    }
    go.sprites = init_sprites(go.w, go.h, go.init_r);
    go.colors = init_colors();
    go.forces = init_forces();
    go.max_run = Math.ceil(go.max_run * 1.18);
    go.n_run = go.max_run;
    init_mob_groups(go);
    build_force_pairs(go);
    return init_graphics(go);
  };

  detect_hits = function(go) {
    var d, hit_player, hit_seed, is_hit, is_valid, name, not_player, results, s, t, targets;
    targets = get_sprite_group(go, 'seed');
    targets.push(go.sprites.dante);
    results = [];
    for (name in go.sprites) {
      results.push((function() {
        var j, len, ref, results1;
        results1 = [];
        for (j = 0, len = targets.length; j < len; j++) {
          t = targets[j];
          s = go.sprites[name];
          d = point_distance(s.cx, s.cy, t.cx, t.cy);
          is_hit = d < (s.r / 2 + t.r / 2);
          is_valid = (ref = s.type) === 'chaser' || ref === 'runner';
          not_player = name !== 'dante';
          hit_seed = t.type === 'seed' && (is_valid || !not_player);
          hit_player = t.name === 'dante' && is_valid && not_player;
          if (is_hit && (hit_seed || hit_player)) {
            results1.push(hit(go, s, t));
          } else {
            results1.push(void 0);
          }
        }
        return results1;
      })());
    }
    return results;
  };

  hit = function(go, sprite, target) {
    var p;
    if (target.name === 'dante') {
      if (go.hit_ctr <= 0) {
        go.hit_img = sprite.img;
        go.hit_ctr = 5;
      }
      if (sprite.type === 'runner') {
        sprite.type = 'chaser';
        del_force_pairs(go, sprite);
        add_force_pairs(go, sprite);
        sprite.img = go.colors.chaser;
        go.n_run--;
        target.r += 5;
        go.score += 5;
      }
      if (sprite.type === 'chaser') {
        p = target;
        if (p.r > go.min_r) {
          p.r--;
        }
        sprite.r--;
        go.score--;
      }
    }
    if (target.type === 'seed') {
      return sprite.r++;
    }
  };

  zero_velocities = function(go) {
    var name, results;
    results = [];
    for (name in go['sprites']) {
      go['sprites'][name]['dvx'] = 0;
      results.push(go['sprites'][name]['dvy'] = 0);
    }
    return results;
  };

  get_pairs = function(go, from_node, to_node) {
    var fn, from_nodes, j, k, len, len1, pairs, tn, to_nodes, types;
    types = get_types(go);
    if (indexOf.call(types, from_node) >= 0) {
      from_nodes = get_sprite_group(go, from_node);
    } else {
      from_nodes = [go['sprites'][from_node]];
    }
    if (indexOf.call(types, to_node) >= 0) {
      to_nodes = get_sprite_group(go, to_node);
    } else {
      to_nodes = [go['sprites'][to_node]];
    }
    pairs = [];
    for (j = 0, len = to_nodes.length; j < len; j++) {
      tn = to_nodes[j];
      for (k = 0, len1 = from_nodes.length; k < len1; k++) {
        fn = from_nodes[k];
        if (tn !== fn) {
          pairs.push([fn, tn]);
        }
      }
    }
    return pairs;
  };

  apply_force = function(go, pair, force) {
    var d, dx, dy, f, v1, v2;
    v1 = pair[0];
    v2 = pair[1];
    d = point_distance(v1.cx, v1.cy, v2.cx, v2.cy);
    dx = v1.cx - v2.cx;
    dy = v1.cy - v2.cy;
    d += 0.0000001;
    f = force(go, d);
    v1.dvx += dx / d * f;
    return v1.dvy += dy / d * f;
  };

  apply_forces = function(go) {
    var fp, j, len, ref, results;
    zero_velocities(go);
    ref = go.force_pairs;
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      fp = ref[j];
      if ((fp[0] != null) && (fp[1] != null)) {
        results.push(apply_force(go, fp.slice(0, 2), fp[2]));
      } else {
        results.push(void 0);
      }
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

  get_types = function(go) {
    return go.types;
  };

  get_sprite_group = function(go, group_type) {
    var group, name, sprite;
    group = [];
    for (name in go["sprites"]) {
      sprite = go["sprites"][name];
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

  init_sprite = function(name, cx, cy, r, img, type) {
    return {
      name: name,
      cx: cx,
      cy: cy,
      r: r,
      img: img,
      type: type,
      dvx: 0,
      dvy: 0,
      vx: 0,
      vy: 0
    };
  };

  move_dante = function(go) {
    var dante;
    dante = go["sprites"]["dante"];
    dante["cx"] = go["mouseX"];
    return dante["cy"] = go["mouseY"];
  };

  move_sprites = function(go) {
    var name, results, sprite, sprites;
    sprites = go['sprites'];
    results = [];
    for (name in sprites) {
      sprite = sprites[name];
      sprite['vx'] += sprite['dvx'];
      sprite['vy'] += sprite['dvy'];
      sprite['cx'] += restrict_v(go, sprite['vx']);
      sprite['cy'] += restrict_v(go, sprite['vy']);
      sprite.dvx = 0;
      results.push(sprite.dvy = 0);
    }
    return results;
  };

  restrict_v = function(go, v) {
    if (v > go.max_v && v > 0) {
      v = go.max_v;
    }
    if (v < -go.max_v && v <= 0) {
      v = -go.max_v;
    }
    return v;
  };

  get_random_color = function() {
    var color, i, j, letters;
    letters = '0123456789ABCDEF';
    color = '#';
    for (i = j = 0; j <= 5; i = ++j) {
      color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
  };

}).call(this);
