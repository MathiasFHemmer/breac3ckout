import std::io;
import std::math;
import raylib5::rl;
import collision;
import std::collections::list;
import components;
import systems;

struct Player {
	float[<2>]	dimensions;
	usz			rigidbody_idx;
}

// Data
List(<Rigidbody>) 			rigidbody_pool;
List(<RotationAnimation>)	anim_rotation_pool;

// Config
const CInt WINDOWS_HEIGHT 	= 600;
const CInt WINDOWS_WIDTH 	= 800;

// Sounds
Sound[6] sound_fx   				= {};
int current_paddle_hit_fx 			= 0;
Sound[10] paddle_hit_audio_channel 	= {};

// Bricks
const int 			BRICKS_LINES 		= 6;
const int 			BRICKS_ROWS 		= 8;
const float[<2>] 	BRICK_DIMENSION 	= {64, 24};
Brick[BRICKS_LINES*BRICKS_ROWS]  bricks = {};


// Ball
float 		ball_radius 	= 5;
float[<2>]	ball_velocity 	= 512;
float[<2>]	ball_position 	= {WINDOWS_WIDTH / 2, WINDOWS_HEIGHT / 2};

// Player
Player		player 				= {{64, 24},0};
float 		score 				= 0;
float 		combo 				= 0;
int 		combo_multiplier 	= 0;
int			kill_count			= 0;


fn void setupBricks(){
	float xSpacing = 8;
	float ySpacing = 8;
	float totalXSpaceing = ((BRICKS_ROWS * (BRICK_DIMENSION.x + xSpacing)) - xSpacing) / 2 - (BRICK_DIMENSION.x/2);
	float totalYSpaceing = ((BRICKS_LINES * (BRICK_DIMENSION.y + ySpacing)) - ySpacing) / 2 - (BRICK_DIMENSION.x/2);

	for(int i = 0; i < BRICKS_LINES*BRICKS_ROWS; i++){
		int line 	= i / BRICKS_ROWS;
		int column 	= i % BRICKS_ROWS;
		int index 	= BRICKS_ROWS*line + column;
		float posX 	= (WINDOWS_WIDTH / 2 - totalXSpaceing + (column * (BRICK_DIMENSION.x + xSpacing)));
		float posY 	= (WINDOWS_HEIGHT / 4 - totalYSpaceing + (line * (BRICK_DIMENSION.y + ySpacing)));

		bricks[index].rigidbody_idx = rigidbody_pool.len();
		rigidbody_pool.push({{posX, posY}, 0, 0});
		bricks[index].is_alive = true;
		bricks[index].lives = (char)math::max(2 - (line/2), 0);

		bricks[index].anim_rotation_idx = anim_rotation_pool.len();
		anim_rotation_pool.push({32.0, 1.0, 2.0, bricks[index].rigidbody_idx});
	}
}

fn void detectBrickCollision(){
	for(int i = 0; i < BRICKS_LINES*BRICKS_ROWS; i++){
		int line = i / BRICKS_ROWS;
		int column = i % BRICKS_ROWS;
		int index = BRICKS_ROWS*line + column;

		if(bricks[index].is_alive == false) continue;

		if (try side = collision::checkCircleOnRectCollision(ball_position, ball_radius, rigidbody_pool[bricks[index].rigidbody_idx].position, BRICK_DIMENSION)){
			switch(side){
				case CollisionSide.BOTTOM:
				case CollisionSide.TOP:
					ball_velocity.y *= -1;
				case CollisionSide.LEFT:
				case CollisionSide.RIGHT:
					ball_velocity.x *= -1;
			}

			combo_multiplier++;
			combo_multiplier = std::math::clamp(combo_multiplier, 0, 5);
			float pow = (float)std::math::pow(2, combo_multiplier);
			(&anim_rotation_pool[0]).speed = pow-1;
			combo = combo + pow;
			score += combo;

			rl::playSound(paddle_hit_audio_channel[current_paddle_hit_fx]);
			current_paddle_hit_fx++;
			current_paddle_hit_fx = current_paddle_hit_fx % paddle_hit_audio_channel.len;

			if(bricks[index].lives > 0){
				bricks[index].lives -= 1;
				kill_count = 0;
				return;
			}

			kill_count++;
			if(kill_count == 2) rl::playSound(sound_fx[2]);
			if(kill_count == 3) rl::playSound(sound_fx[3]);
			if(kill_count == 4) rl::playSound(sound_fx[4]);
			if(kill_count == 5) rl::playSound(sound_fx[5]);
			bricks[index].is_alive = false;
			
		}
	}
}

fn void drawScore(){
	ZString score_text = std::core::string::tformat_zstr("SCORE: %d", score);
	Vector2 score_text_position = {rigidbody_pool[1].position.x, rigidbody_pool[1].position.y};
	ZString combo_text = std::core::string::tformat_zstr("COMBO: %2.1f (+ %d)", combo, std::math::pow(2, combo_multiplier));
	rl::drawTextPro(rl::getFontDefault(), score_text, score_text_position, {(float)rl::measureText(score_text, 18)/2,0}, rigidbody_pool[1].rotation, 18, 2, rl::WHITE);
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
		if(try side = collision::checkCircleOnRectCollision(ball_position, ball_radius, rigidbody_pool[player.rigidbody_idx].position, player.dimensions)){
			combo_multiplier = 0;
			(&anim_rotation_pool[0]).speed = 0;
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
	if(rl::isKeyDown(rl::KEY_LEFT) && rigidbody_pool[player.rigidbody_idx].position.x - player.dimensions.x/2  > 0){
		rigidbody_pool[player.rigidbody_idx].position.x -= rigidbody_pool[player.rigidbody_idx].velocity * rl::getFrameTime();
	};
	if(rl::isKeyDown(rl::KEY_RIGHT) && rigidbody_pool[player.rigidbody_idx].position.x + player.dimensions.x/2 < WINDOWS_WIDTH){
		rigidbody_pool[player.rigidbody_idx].position.x += rigidbody_pool[player.rigidbody_idx].velocity * rl::getFrameTime();
	};
}

fn void updateUI(){
	rl::beginDrawing();
		rl::clearBackground(rl::BLACK);
		//rl::drawFPS(0, 0);
		drawScore();
		rl::drawCircle((int)ball_position.x, (int)ball_position.y, (int)ball_radius, { 255, 255, 255, 255 });
		Rectangle rec = {
			rigidbody_pool[player.rigidbody_idx].position.x,
			rigidbody_pool[player.rigidbody_idx].position.y,
			player.dimensions.x,
			player.dimensions.y
			};
		rl::drawRectanglePro(rec, {player.dimensions.x/2,player.dimensions.y/2}, rigidbody_pool[0].rotation, rl::WHITE);
		
		for(int i = 0; i < BRICKS_LINES*BRICKS_ROWS; i++){
			int line 	= i / BRICKS_ROWS;
			int column 	= i % BRICKS_ROWS;
			int index 	= BRICKS_ROWS*line + column;

			if(bricks[index].is_alive == false) continue;
			rec = {
				rigidbody_pool[bricks[index].rigidbody_idx].position.x, 
				rigidbody_pool[bricks[index].rigidbody_idx].position.y,
				BRICK_DIMENSION.x,
				BRICK_DIMENSION.y
				};
			rl::drawRectanglePro(rec, {BRICK_DIMENSION.x/2,BRICK_DIMENSION.y/2}, rigidbody_pool[bricks[index].rigidbody_idx].rotation, components::BRICKS_COLOR[bricks[index].lives]);
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
	
	sound_fx = {
		rl::loadSound("resources/pop.ogg"),
		rl::loadSound("resources/paddle_hit.ogg"),
		rl::loadSound("resources/double_kill.ogg"),
		rl::loadSound("resources/triple_kill.ogg"),
		rl::loadSound("resources/ultra_kill.ogg"),
		rl::loadSound("resources/rampage.ogg")
	};
	for(int x = 0; x < paddle_hit_audio_channel.len; x++) paddle_hit_audio_channel[x] = rl::loadSoundAlias(sound_fx[0]);

	// Init components
	rigidbody_pool.push({
		float[<2>]{ (int)((double)WINDOWS_WIDTH * 0.5), (int)((double)WINDOWS_HEIGHT * 0.85)},
		800,
		0
	});

	rigidbody_pool.push({
		float[<2>]{(float)(WINDOWS_WIDTH/2), (float)(WINDOWS_HEIGHT - 60)},
		0,
		0
	});

	anim_rotation_pool.push({1.0, 1.0, 3.0, 1});
	//anim_rotation_pool.push({32.0, 1.0, 180.0, 0});

	setupBricks();

	while(!rl::windowShouldClose()){
		systems::update_animation(anim_rotation_pool, rigidbody_pool, rl::getFrameTime());

		processInput();
		updatePhysics();
		updateUI();

		combo = combo - combo * 0.1 * rl::getFrameTime();
		if(combo <= 1) combo = 1;
	}

	
	return 0;
}