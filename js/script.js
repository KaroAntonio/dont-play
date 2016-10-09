var game_objs;

var width = window.innerWidth,
	height = window.innerHeight;

$(document).ready(function() {
	$('#loading').hide();

	game_objs = init_game(width, height);
	init_graphics(game_objs);
	loop();
})

function loop() {

	update(game_objs);
	render(game_objs);

	requestAnimationFrame(loop);	
}


