import std::io;
import std::math;
import raylib5::rl;
import collision;

struct RotationAnimation{
	float speed;
	float direction;
	float max_rotation;
	float* target;
}

struct Brick{
	float[<2>] position;
	bool is_alive;
}

// Config
const CInt WINDOWS_HEIGHT 	= 600;
const CInt WINDOWS_WIDTH 	= 800;

// Sounds
Sound[2] sound_fx   				= {};
int current_paddle_hit_fx 			= 0;
Sound[10] paddle_hit_audio_channel 	= {};

// Bricks
const int 			BRICKS_LINES 		= 6;
const int 			BRICKS_ROWS 		= 8;
const float[<2>] 	BRICK_DIMENSION 	= {64, 24};
Brick[BRICKS_LINES*BRICKS_ROWS]  bricks = {};


// Ball
float 		ball_radius = 5;
float[<2>]	ball_velocity = 512;
float[<2>]	ball_position = {WINDOWS_WIDTH / 2, WINDOWS_HEIGHT / 2};

// Player
float[<2>]	player_dimensions 	= {64, 24};
float[<2>]	player_position 	= { (int)((double)WINDOWS_WIDTH * 0.5), (int)((double)WINDOWS_HEIGHT * 0.85)};
float 		player_velocity		= 800;
float 		score 				= 0;
float 		combo 				= 0;
int 		combo_multiplier 	= 0;

// UI
float[<2>]	score_txt_position = {(float)(WINDOWS_WIDTH/2), (float)(WINDOWS_HEIGHT - 60)};
float		score_txt_rotation = 0;
RotationAnimation score_txt_tween = {1.0, 1.0, 3.0, null};

fn void setupBricks(){
	float xSpacing = 8;
	float ySpacing = 8;
	float totalXSpaceing = ((BRICKS_ROWS * (BRICK_DIMENSION.x + xSpacing)) - xSpacing) / 2 - (BRICK_DIMENSION.x/2);
	float totalYSpaceing = ((BRICKS_LINES * (BRICK_DIMENSION.y + ySpacing)) - ySpacing) / 2 - (BRICK_DIMENSION.y/2);

	for(int i = 0; i < BRICKS_LINES*BRICKS_ROWS; i++){
		int line 	= i / BRICKS_ROWS;
		int column 	= i % BRICKS_ROWS;
		int index 	= BRICKS_ROWS*line + column;
		float posX 	= (WINDOWS_WIDTH / 2 - totalXSpaceing + (column * (BRICK_DIMENSION.x + xSpacing)));
		float posY 	= (WINDOWS_HEIGHT / 5 - totalYSpaceing + (line * (BRICK_DIMENSION.y + ySpacing)));

		bricks[index].position = {posX, posY};
		bricks[index].is_alive = true;
	}
}

fn void detectBrickCollision(){
	for(int i = 0; i < BRICKS_LINES*BRICKS_ROWS; i++){
		int line = i / BRICKS_ROWS;
		int column = i % BRICKS_ROWS;
		int index = BRICKS_ROWS*line + column;

		if(bricks[index].is_alive == false) continue;

		if (try side = collision::checkCircleOnRectCollision(ball_position, ball_radius, bricks[index].position, BRICK_DIMENSION)){
			switch(side){
				case CollisionSide.BOTTOM:
				case CollisionSide.TOP:
					ball_velocity.y *= -1;
				case CollisionSide.LEFT:
				case CollisionSide.RIGHT:
					ball_velocity.x *= -1;
			}
			rl::playSound(paddle_hit_audio_channel[current_paddle_hit_fx]);
			current_paddle_hit_fx++;
			current_paddle_hit_fx = current_paddle_hit_fx % paddle_hit_audio_channel.len;
			bricks[index].is_alive = false;
			combo_multiplier++;
			combo_multiplier = std::math::clamp(combo_multiplier, 0, 5);
			score_txt_tween.speed = (float)std::math::pow(2, combo_multiplier) -1;
			combo = combo + (float)std::math::pow(2, combo_multiplier);
			score += combo;
		}
	}
}

fn void drawScore(){
	ZString score_text = std::core::string::tformat_zstr("SCORE: %d", score);
	Vector2 score_text_position = {score_txt_position.x, score_txt_position.y};
	ZString combo_text = std::core::string::tformat_zstr("COMBO: %2.1f (+ %d)", combo, std::math::pow(2, combo_multiplier));
	rl::drawTextPro(rl::getFontDefault(), score_text, score_text_position, {(float)rl::measureText(score_text, 18)/2,0}, score_txt_rotation, 18, 2, rl::WHITE);
	//rl::drawText(score_text, WINDOWS_WIDTH/2 - rl::measureText(score_text, 18)/2, WINDOWS_HEIGHT - 60, 18, rl::WHITE);
	rl::drawText(combo_text, WINDOWS_WIDTH/2 - rl::measureText(combo_text, 18)/2, WINDOWS_HEIGHT - 40, 18, rl::WHITE);
}

fn void updatePhysics(){
		detectBrickCollision();
		
		if(ball_position.x + ball_radius * 2 > WINDOWS_WIDTH || ball_position.x - ball_radius * 2 <= 0){
			ball_velocity.x *= -1;
		}
		if(ball_position.y + ball_radius * 2 >= WINDOWS_HEIGHT || ball_position.y - ball_radius * 2 <= 0){
			ball_velocity.y *= -1;
		}
		
		ball_position += ball_velocity * rl::getFrameTime();

		// Paddle Collistion Detection
		if(try side = collision::checkCircleOnRectCollision(ball_position, ball_radius, player_position, player_dimensions)){
			combo_multiplier = 0;
			score_txt_tween.speed = 0;
			//TODO: Handle collision penetration
			rl::playSound(sound_fx[1]);
			switch(side){
				case CollisionSide.BOTTOM:
				case CollisionSide.TOP:
					ball_velocity.y *= -1;
				case CollisionSide.LEFT:
				case CollisionSide.RIGHT:
					ball_velocity.x *= -1;
			}
		}
}

fn void processInput(){
	// Handle Paddle Movement
	if(rl::isKeyDown(rl::KEY_LEFT) && player_position.x - player_dimensions.x / 2 > 0){
		player_position -= float[<2>]{player_velocity, 0} * rl::getFrameTime();
	};
	if(rl::isKeyDown(rl::KEY_RIGHT) && player_position.x + player_dimensions.x / 2 < WINDOWS_WIDTH){
		player_position += float[<2>]{player_velocity, 0} * rl::getFrameTime();
	};
}

fn void updateUI(){
	rl::beginDrawing();
		rl::clearBackground(rl::BLACK);
		rl::drawFPS(0, 0);
		drawScore();
		rl::drawCircle((int)ball_position.x, (int)ball_position.y, (int)ball_radius, { 255, 255, 255, 255 });
		rl::drawRectangle((int)(player_position.x - player_dimensions.x / 2), (int)(player_position.y - player_dimensions.y / 2), (int)player_dimensions.x, (int)player_dimensions.y, rl::WHITE);
		
		for(int i = 0; i < BRICKS_LINES*BRICKS_ROWS; i++){
			int line 	= i / BRICKS_ROWS;
			int column 	= i % BRICKS_ROWS;
			int index 	= BRICKS_ROWS*line + column;

			if(bricks[index].is_alive == false) continue;
			rl::drawRectangle((int)(bricks[index].position.x - BRICK_DIMENSION.x/2), (int)(bricks[index].position.y - BRICK_DIMENSION.y/2), (int)BRICK_DIMENSION.x , (int)BRICK_DIMENSION.y, rl::WHITE);
		}	
	rl::endDrawing();
}

fn int main(String[] args) //@winmain
{
	rl::setTargetFPS(120);
	rl::initWindow(WINDOWS_WIDTH, WINDOWS_HEIGHT, "Brick Breaker");
	defer rl::closeWindow();
	rl::initAudioDevice();
	defer rl::closeAudioDevice();
	
	score_txt_tween.target = &score_txt_rotation;
	
	sound_fx = {
		rl::loadSound("resources/pop.ogg"),
		rl::loadSound("resources/paddle_hit.ogg")
	};
	for(int x = 0; x < paddle_hit_audio_channel.len; x++) paddle_hit_audio_channel[x] = rl::loadSoundAlias(sound_fx[0]);

	setupBricks();

	while(!rl::windowShouldClose()){
		*score_txt_tween.target += score_txt_tween.speed * (float)rl::getFrameTime() * score_txt_tween.direction;
		if(std::math::abs(*score_txt_tween.target) > score_txt_tween.max_rotation) score_txt_tween.direction *= -1;

		processInput();
		updatePhysics();
		updateUI();

		combo = combo - combo * 0.1 * rl::getFrameTime();
		if(combo <= 1) combo = 1;
	}

	
	return 0;
}



