
var game_objs;

var width = window.innerWidth,
	height = window.innerHeight;

$(document).ready(function() {
	$('#loading').hide();

	game_objs = init_game(width, height);
	init_graphics(game_objs);

	loop();

	$(window).mousemove(function(evt) {
		game_objs['mouseX'] = evt.clientX;
		game_objs['mouseY'] = evt.clientY;
	})
})

function loop() {

	update(game_objs);
	render(game_objs);

	requestAnimationFrame(loop);	
}
