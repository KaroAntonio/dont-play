// Generated by CoffeeScript 1.11.1
(function() {
  var init_sprite_div, render_background, render_hud, render_sprites;

  window.init_graphics = function(game_objs) {
    var name, score;
    for (name in game_objs["sprites"]) {
      init_sprite_div(game_objs, name);
    }
    if (game_objs.hud != null) {
      game_objs.hud.score.remove();
    }
    score = $("<div>");
    score.css({
      position: "fixed",
      height: 50,
      width: 50,
      left: 25,
      top: game_objs.h - 50,
      fontSize: 20,
      fontFamily: 'monospace'
    });
    score.appendTo($('body'));
    game_objs['hud'] = {
      score: score
    };
    return $("body").css({
      height: "100vh",
      width: "100vw"
    });
  };

  window.render = function(game_objs) {
    render_background(game_objs);
    render_sprites(game_objs);
    return render_hud(game_objs);
  };

  init_sprite_div = function(go, name) {
    var new_div, sprite;
    sprite = game_objs["sprites"][name];
    new_div = $("<div>");
    new_div.css({
      position: "fixed",
      height: sprite["r"],
      width: sprite["r"],
      fill: sprite["img"]
    });
    $("body").append(new_div);
    return sprite["div"] = new_div;
  };

  render_background = function(go) {
    return 'if go.hit_ctr > 0\n	$(\'body\').css\n		background: go.hit_img\nelse\n	$(\'body\').css\n		background: \'#fff\'';
  };

  render_hud = function(go) {
    return go.hud.score.text(go.score);
  };

  render_sprites = function(game_objs) {
    var name, p, r, ref, results, s;
    results = [];
    for (name in game_objs["sprites"]) {
      s = game_objs["sprites"][name];
      if (s.div == null) {
        init_sprite_div(game_objs, name);
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
        p = game_objs.sprites.dante;
        r = p.r + 20;
        s.div.css({
          left: p.cx - r / 2,
          top: p.cy - r / 2,
          height: r,
          width: r
        });
        if (game_objs.hit_ctr > 0) {
          s.div.css({
            background: game_objs.hit_img
          });
        }
      }
      if ((ref = s.type) === 'repulsor' || ref === 'attractor') {
        s.div.css({
          zIndex: -2
        });
      }
      if (name === 'dante') {
        results.push(s["div"].css);
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

}).call(this);
