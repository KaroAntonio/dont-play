var game_objs, msgs;

var width = window.innerWidth,
	height = window.innerHeight;

$(document).ready(function() {
	$.getJSON( "assets/words.json", function( msgs ) {

		game_objs = init_game(width, height, msgs);
		init_graphics(game_objs);

		$('#loading').hide();
		loop();
	});
})

function loop() {

	update(game_objs);
	render(game_objs);

	requestAnimationFrame(loop);	
}


