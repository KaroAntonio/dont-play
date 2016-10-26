// Generated by CoffeeScript 1.11.1
(function() {
  var fade_dead_cubes, fade_dead_sprites, init_bg, init_body, init_color, init_info, init_msg, init_score, init_sprite_cube, init_sprite_cubes, init_sprite_div, init_sprite_divs, init_three, render_background, render_cubes, render_hud, render_info, render_msg, render_sprites, set_msg;

  window.init_graphics = function(go) {
    if (go.three == null) {
      init_three(go);
    }
    init_bg(go);
    init_score(go);
    init_info(go);
    init_msg(go);
    init_sprite_cubes(go);
    init_body(go);
    return fade_dead_cubes(go);
  };

  init_three = function(go) {
    var Light1, camera, renderer, scene, three_div;
    three_div = $('<div>');
    three_div.css({
      margin: 0,
      position: 'fixed',
      zIndex: -2
    });
    three_div.appendTo('body');
    camera = new THREE.PerspectiveCamera(90, window.innerWidth / window.innerHeight, 0.1, 10000);
    renderer = new THREE.WebGLRenderer({
      antialias: true,
      alpha: true
    });
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0xff0000);
    camera.position.z = 300;
    camera.lookAt(new THREE.Vector3(0, 0, 0));
    scene.add(camera);
    renderer.setSize(window.innerWidth, window.innerHeight);
    three_div.append(renderer.domElement);
    Light1 = new THREE.PointLight(0xffffff, 1);
    Light1.position.x = 1500;
    Light1.position.z = 4000;
    scene.add(Light1);
    return go['three'] = {
      div: three_div,
      camera: camera,
      scene: scene,
      renderer: renderer
    };
  };

  init_color = function(s) {
    var c;
    return c = new THREE.MeshPhongMaterial({
      color: s.img,
      specular: s.img,
      emissive: s.img,
      shininess: 2,
      transparent: true,
      opacity: s.opacity,
      shading: THREE.FlatShading
    });
  };

  init_sprite_cube = function(go, name) {
    var cube, r, s;
    s = go["sprites"][name];
    r = go.max_r;
    cube = new THREE.Mesh(new THREE.BoxGeometry(r, r, 10), init_color(s));
    go.three.scene.add(cube);
    return s["cube"] = cube;
  };

  init_sprite_cubes = function(go) {
    var name, results;
    results = [];
    for (name in go.sprites) {
      results.push(init_sprite_cube(go, name));
    }
    return results;
  };

  init_sprite_divs = function(go) {
    var name, results;
    results = [];
    for (name in go["sprites"]) {
      results.push(init_sprite_div(go, name));
    }
    return results;
  };

  init_body = function(go) {
    return $('body').css({
      fontFamily: 'monospace',
      position: 'fixed'
    });
  };

  init_score = function(go) {
    var score;
    if (go.hud != null) {
      go.hud.score.remove();
    }
    score = $("<div>");
    score.appendTo('body');
    score.css({
      position: "fixed",
      height: 50,
      width: 50,
      left: 25,
      top: go.h - 50,
      fontSize: 20
    });
    return go['hud'] = {
      score: score
    };
  };

  init_bg = function(go) {
    var bg;
    if (go.bg != null) {
      go.bg.remove();
    }
    bg = $("<div>");
    bg.appendTo('body');
    go.bg = bg;
    return bg.css({
      position: "fixed",
      height: "100vh",
      width: "100vw",
      zIndex: -100
    });
  };

  window.render = function(go) {
    render_background(go);
    render_cubes(go);
    render_hud(go);
    render_info(go);
    render_msg(go);
    return go.three.renderer.render(go.three.scene, go.three.camera);
  };

  init_msg = function(go) {
    var msg;
    if (go.msg == null) {
      msg = $('<div>');
      go['msg'] = msg;
      msg.appendTo('body');
      msg.css({
        position: 'fixed',
        top: go.h * 0.4,
        width: go.w,
        zIndex: -2,
        textAlign: 'center',
        fontSize: 28
      });
      return set_msg(go);
    }
  };

  init_info = function(go) {
    var info;
    if (go.info == null) {
      info = $('<div>');
      go['info'] = info;
      info.appendTo('body');
      info.css({
        position: "absolute",
        overflow: 'scroll',
        height: go.h * 0.6,
        width: go.w * 0.6,
        padding: 15,
        marginTop: go.h * 0.2,
        marginLeft: go.w * 0.2,
        marginRight: go.w * 0.2,
        marginBottom: go.w * 0.2,
        fontSize: 25,
        background: '#fff'
      });
      return info.html('DANTE: DONT PLAY THIS  <br>Chase the ones that run away from you, <br>run from the ones that chase you, simple ;) <br>The numbers on the bottom left work like: <br>score // life // runners left <br><br>A: spawn a seed, warning: super growey  <br>S: spaw a repulsor, pushes things away <br>D: spa an attractor, like a mini black-hole <br>F: sp a chaser... he gonna get u <br>H: Pause/Open this Menu 	<br>MOUSE: move <br><br>>> PRESS ANY KEY TO START <<<br> <br>RULES:<br> - Chasers are attracted to you. <br> - Runners are attracted to chasers and repulsed from you, <br> the bigger you get, the faster they run  away from you. <br> - You grow bigger when you eat runners and get smaller when chasers eat you. You also get smaller when you spawn attractors and repulsors. ');
    }
  };

  set_msg = function(go) {
    var i;
    i = Math.floor(Math.random() * go.msgs.length);
    return go.msg.html(go.msgs[i]);
  };

  render_msg = function(go) {
    var w1;
    w1 = (Math.sin(go.t / 50) + 1) / 2;
    go.msg.css({
      opacity: w1
    });
    if (go.msg.css('opacity') <= 0.01) {
      return set_msg(go);
    }
  };

  render_info = function(go) {
    if (go.paused) {
      return go.info.css({
        zIndex: 1
      });
    } else {
      return go.info.css({
        zIndex: -101
      });
    }
  };

  fade_dead_cubes = function(go) {
    var name, results, s;
    results = [];
    for (name in go.dead_sprites) {
      s = go.dead_sprites[name];
      if (s.cube != null) {
        s.cube.position.z -= 20;
        s.cube.scale.z = 0.4;
        s.opacity *= 0.7;
        results.push(s.cube.material = init_color(s));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  fade_dead_sprites = function(go) {
    var name, results, s;
    results = [];
    for (name in go.dead_sprites) {
      s = go.dead_sprites[name];
      if (s.div != null) {
        results.push(s.div.css({
          opacity: s.div.css('opacity') * 0.6,
          zIndex: -3
        }));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  init_sprite_div = function(go, name) {
    var new_div, sprite;
    sprite = go["sprites"][name];
    new_div = $("<div>");
    new_div.css({
      position: "fixed",
      height: sprite["r"],
      width: sprite["r"],
      fill: sprite["img"],
      opacity: 1
    });
    $("body").append(new_div);
    return sprite["div"] = new_div;
  };

  render_background = function(go) {
    '	';
    var c, w1, w2;
    w1 = (Math.sin(go.t / 1000) + 1) / 2;
    w2 = (Math.cos(go.t / 5000) + 1) / 2;
    c = w1 * w2 * 240 + 120;
    return go.bg.css({
      background: 'hsl(' + c + ',100%,97%)'
    });
  };

  render_hud = function(go) {
    return go.hud.score.text(go.score + '//' + go.sprites.dante.r + '//' + go.n_run);
  };

  render_cubes = function(go) {
    var cs, cube, name, ref, results, s;
    results = [];
    for (name in go["sprites"]) {
      s = go["sprites"][name];
      if (s.cube == null) {
        init_sprite_cube(go, name);
      }
      cube = s.cube;
      if (name === 'hit') {
        s = go.sprites.dante;
      }
      cube.position.x = s.cx - go.w / 2;
      cube.position.y = -(s.cy - go.h / 2);
      cube.material = init_color(s);
      cs = s.r / go.max_r;
      if (name === 'hit') {
        if (go.hit_ctr > 0) {
          cs = (s.r + 20) / go.max_r;
        } else {
          cs = 0.00001;
        }
      }
      cube.scale.set(cs, cs, cs);
      if ((ref = s.type) === 'repulsor' || ref === 'attractor' || ref === 'seed') {
        cube.scale.z = 1;
        results.push(cube.position.z = -20);
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  render_sprites = function(go) {
    var name, p, r, ref, results, s;
    results = [];
    for (name in go["sprites"]) {
      s = go["sprites"][name];
      if (s.div == null) {
        init_sprite_div(go, name);
      }
      s["div"].css({
        background: s["img"],
        fill: s["img"],
        left: s["cx"] - s["r"] / 2,
        top: s["cy"] - s["r"] / 2,
        height: s["r"],
        width: s["r"]
      });
      if (name === 'hit') {
        p = go.sprites.dante;
        r = p.r + 20;
        s.div.css({
          left: p.cx - r / 2,
          top: p.cy - r / 2,
          height: r,
          width: r
        });
        if (go.hit_ctr > 0) {
          s.div.css({
            background: go.hit_img
          });
        }
      }
      if ((ref = s.type) === 'repulsor' || ref === 'attractor' || ref === 'seed') {
        results.push(s.div.css({
          zIndex: -1
        }));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

}).call(this);
