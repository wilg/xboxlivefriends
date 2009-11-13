var isAnimating = false;
var animationDuration = 0.4;

function load_details(game_id, row_id) {
	var replace_id = "details_" + row_id;
	if (!isAnimating) {
		log("loading");
		isAnimating = true;
		$("game_" + row_id).toggleClassName("achievements_open");
		if( !$(replace_id).visible() ) {
			if( $(replace_id).innerHTML == "" ) {
				achievements_source = XBCompareAchievements.beginLoadingDetailsForGame_row_(game_id, row_id);
				return;
			}
			open_row(row_id);
		}
		else {
			close_row(row_id);
		}
		
	}
}

function open_row(row_id) {
	new Effect.Opacity("details_" + row_id, { duration:animationDuration, from:0.0, to:1.0});
	new Effect.BlindDown("details_" + row_id, {duration:animationDuration,  afterFinish: enable_animation});
	$("game_" + row_id).getElementsByClassName("disclosure")[0].hide();
	$("game_" + row_id).getElementsByClassName("disclosure_up")[0].show();
	$("game_" + row_id).addClassName("achievements_open");
}

function close_row(row_id) {
	new Effect.Opacity("details_" + row_id, { duration:animationDuration, from:1.0, to:0.0});
	new Effect.BlindUp("details_" + row_id, {duration:animationDuration,  afterFinish: function(x){
		enable_animation();
		$("game_" + row_id).removeClassName("achievements_open");
	}});
	$("game_" + row_id).getElementsByClassName("disclosure")[0].show();
	$("game_" + row_id).getElementsByClassName("disclosure_up")[0].hide();
}

function details_loaded(achievements_source, game_id, row_id) {
	log("row id = " + row_id);

	achievements_source = achievements_source + "<div class=\"closer\" onclick=\"load_details('" + game_id + "', '" + row_id + "');location.hash = 'anchor_" + game_id + "'\"><img src='up_chevron.png' /></div>";
	$("details_" + row_id).innerHTML = achievements_source;
	
	open_row(row_id);
}

function log(x) {
//	$("debug").innerHTML = x;
}

function enable_animation() {
	isAnimating = false;
}