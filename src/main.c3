import std::io;
import std::math;
import raylib5::rl;
import collision;
import std::collections::list;
import components;
import systems;
import systems::tween;
import systems::particles;
import entities;

struct Player {
	float[<2>]	dimensions;
	usz			rigidbody_idx;
}

// Data
List(<Rigidbody>) 			rigidbody_pool;
List(<ShapeBox>)			shapebox_pool;
List(<AnimateRotation>)		anim_rotation_pool;
List(<AnimatePosition>)		pos_animation_pool;
List(<Puck>)				puck_pool;
List(<Emitter>)				emitter_pool;
List(<Particle>)			particle_pool;
SlowTime					slow_time;

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
//float 		ball_radius 	= 5;
//float[<2>]	ball_velocity 	= 512;
//float[<2>]	ball_position 	= {WINDOWS_WIDTH / 2, WINDOWS_HEIGHT / 2};

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
		rigidbody_pool.push({{posX, posY}, {0,0}, 0});
		bricks[index].is_alive = true;
		bricks[index].lives = (char)math::max(2 - (line/2), 0);

			bricks[index].anim_rotation_idx = pos_animation_pool.len();
			pos_animation_pool.push({
				{true, true, 10, 0, TweenType.SINEEASYINOUT, 0},
				bricks[index].rigidbody_idx, {posX, posY}, {posX, posY+200}});
		
	}
}

fn void detectBrickCollision(){
	for(int i = 0; i < BRICKS_LINES*BRICKS_ROWS; i++){
		int line = i / BRICKS_ROWS;
		int column = i % BRICKS_ROWS;
		int index = BRICKS_ROWS*line + column;

		if(bricks[index].is_alive == false) continue;

		if (try side = collision::checkCircleOnRectCollision(rigidbody_pool[puck_pool[0].rigidbody_idx].position, shapebox_pool[puck_pool[0].shape_idx].circle.radius, rigidbody_pool[bricks[index].rigidbody_idx].position, BRICK_DIMENSION)){
			switch(side){
				case CollisionSide.BOTTOM:
				case CollisionSide.TOP:
					rigidbody_pool[puck_pool[0].rigidbody_idx].velocity.y *= -1;
				case CollisionSide.LEFT:
				case CollisionSide.RIGHT:
					rigidbody_pool[puck_pool[0].rigidbody_idx].velocity.x *= -1;
			}

			combo_multiplier++;
			combo_multiplier = std::math::clamp(combo_multiplier, 0, 5);
			float pow = (float)std::math::pow(2, combo_multiplier);
			anim_rotation_pool[0].length = 1.0 / (float)combo_multiplier;
			combo = combo + pow;
			score += combo;

			rl::playSound(paddle_hit_audio_channel[current_paddle_hit_fx]);
			current_paddle_hit_fx++;
			current_paddle_hit_fx = current_paddle_hit_fx % paddle_hit_audio_channel.len;

			emitter_pool.push({
				true,
				rigidbody_pool[bricks[index].rigidbody_idx].position,
				true,
				components::BRICKS_COLOR[bricks[index].lives]
			});
			
			if(bricks[index].lives > 0){
				bricks[index].lives -= 1;
				kill_count = 0;
				return;
			}

			kill_count++;
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

	Rectangle power_bar = {WINDOWS_WIDTH/2 -25, WINDOWS_HEIGHT-10, 50, 5};
	Rectangle power_bar_bg = {WINDOWS_WIDTH/2 -27, WINDOWS_HEIGHT-12, 54, 9};
	Color bar_color = slow_time.is_burnout ? rl::RED : rl::GREEN;

	power_bar.width = (float)(power_bar.width * slow_time.duration_current/slow_time.duration_max);

	rl::drawRectanglePro(power_bar_bg, {0, 0}, 0, rl::WHITE);
	rl::drawRectanglePro(power_bar, {0, 0}, 0, bar_color);
}

fn void updatePhysics(){
		detectBrickCollision();
		
		Rigidbody* puck_rigidibody = &rigidbody_pool[puck_pool[0].rigidbody_idx];
		ShapeBox* puck_shapebox = &shapebox_pool[puck_pool[0].shape_idx];
		
		if(puck_rigidibody.position.x + puck_shapebox.circle.radius * 2 > WINDOWS_WIDTH || puck_rigidibody.position.x - puck_shapebox.circle.radius * 2 <= 0){
			puck_rigidibody.velocity.x *= -1;
		}
		if(puck_rigidibody.position.y + 5 * 2 >= WINDOWS_HEIGHT || puck_rigidibody.position.y - 5 * 2 <= 0){
			puck_rigidibody.velocity.y *= -1;
		}
		
		double dt = (rl::getFrameTime() * slow_time.value);
		puck_rigidibody.position +=  puck_rigidibody.velocity * (float[<2>]) dt;

		// Paddle Collistion Detection
		if(try side = collision::checkCircleOnRectCollision(puck_rigidibody.position, puck_shapebox.circle.radius, rigidbody_pool[player.rigidbody_idx].position, player.dimensions)){
			combo_multiplier = 0;
			//TODO: Handle collision penetration
			rl::playSound(sound_fx[1]);
			switch(side){
				case CollisionSide.BOTTOM:
				case CollisionSide.TOP:
					puck_rigidibody.velocity.y *= -1;
				case CollisionSide.LEFT:
				case CollisionSide.RIGHT:
					puck_rigidibody.velocity.x *= -1;
			}
		}
}

fn void processInput(){
	// Handle Paddle Movement
	if(rl::isKeyDown(rl::KEY_LEFT) && rigidbody_pool[player.rigidbody_idx].position.x - player.dimensions.x/2  > 0){
		(&rigidbody_pool[player.rigidbody_idx]).position -= rigidbody_pool[player.rigidbody_idx].velocity * rl::getFrameTime();
	};
	if(rl::isKeyDown(rl::KEY_RIGHT) && rigidbody_pool[player.rigidbody_idx].position.x + player.dimensions.x/2 < WINDOWS_WIDTH){
		(&rigidbody_pool[player.rigidbody_idx]).position += rigidbody_pool[player.rigidbody_idx].velocity * rl::getFrameTime();
	};
	if(rl::isKeyPressed(rl::KEY_SPACE)){
		slow_time.start();
	}
	if (rl::isKeyReleased(rl::KEY_SPACE)){
		slow_time.stop();
	};
}

fn void updateUI(){
	rl::beginDrawing();
		rl::clearBackground(rl::BLACK);
		rl::drawFPS(0, 0);
		drawScore();
		Rectangle rec = {
			rigidbody_pool[player.rigidbody_idx].position.x,
			rigidbody_pool[player.rigidbody_idx].position.y,
			player.dimensions.x,
			player.dimensions.y
			};
		rl::drawRectanglePro(rec, {player.dimensions.x/2,player.dimensions.y/2}, rigidbody_pool[0].rotation, rl::WHITE);

		foreach(idx, shape : shapebox_pool){
			switch(shape.type){
				case ShapeType.CIRCLE:
				default:
				rl::drawCircle((int)rigidbody_pool[shape.rigidbody_idx].position.x, (int)rigidbody_pool[shape.rigidbody_idx].position.y, shape.circle.radius, { 255, 255, 255, 255 });
			};
		}
		
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

		foreach(particle: particle_pool){
			rl::drawCircle((int)(particle.rigidbody.position.x + emitter_pool[particle.emitter_idx].position.x), (int)(particle.rigidbody.position.y + emitter_pool[particle.emitter_idx].position.y), particle.shape.circle.radius, particle.color);
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
	};
	for(int x = 0; x < paddle_hit_audio_channel.len; x++) paddle_hit_audio_channel[x] = rl::loadSoundAlias(sound_fx[0]);

	// Init components
	// player
	rigidbody_pool.push({
		float[<2>]{ (int)((double)WINDOWS_WIDTH * 0.5), (int)((double)WINDOWS_HEIGHT * 0.85)},
		{800,0},
		0
	});
	// score text
	rigidbody_pool.push({
		float[<2>]{(float)(WINDOWS_WIDTH/2), (float)(WINDOWS_HEIGHT - 60)},
		{0,0},
		0
	});
	anim_rotation_pool.push({
				{true, true, 1, 0, TweenType.SINEEASYINOUT, 0},
				1, 0, 3});

	slow_time = SlowTime{false, 4.0, 0.0, 0.35, 1.0, false, 0.0, 2.0};
	
	//Puck Setup
	usz puck_rigidibody_idx = rigidbody_pool.len();
	rigidbody_pool.push({
		float[<2>]{(float)(WINDOWS_WIDTH/2), (float)(WINDOWS_HEIGHT-50)},
		{512,512},
		0
	});
	usz puck_shapebox_idx = shapebox_pool.len();
	shapebox_pool.push({ShapeType.CIRCLE, puck_rigidibody_idx, {5}});
	puck_pool.push({
		puck_rigidibody_idx,
		puck_shapebox_idx
	});

	usz puck_rigidibody_idx2 = rigidbody_pool.len();
	rigidbody_pool.push({
		float[<2>]{(float)(WINDOWS_WIDTH/2), (float)(WINDOWS_HEIGHT-50)},
		{512,512},
		0
	});
	usz puck_shapebox_idx2 = shapebox_pool.len();
	shapebox_pool.push({ShapeType.CIRCLE, puck_rigidibody_idx2, {5}});
	puck_pool.push({
		puck_rigidibody_idx2,
		puck_shapebox_idx2
	});


	setupBricks();
	
	bool win = false;
	while(!rl::windowShouldClose()){
		if(win){
			rl::beginDrawing();
				rl::clearBackground(rl::BLACK);
				rl::drawText("You Win!", WINDOWS_WIDTH/2, WINDOWS_HEIGHT/2, 26, rl::WHITE);
			rl::endDrawing();
			continue;
		}

		systems::particles::update_emitter(&emitter_pool, &particle_pool);
		systems::particles::update_particle(&particle_pool, rl::getFrameTime());
		systems::update_slow_time(&slow_time, rl::getFrameTime());
		systems::tween::update_animate_rotation(anim_rotation_pool, rigidbody_pool, rl::getFrameTime());
		systems::tween::update_animate_position(pos_animation_pool, rigidbody_pool, rl::getFrameTime());
		
		processInput();
		updatePhysics();
		updateUI();

		combo = combo - combo * 0.1 * rl::getFrameTime();
		if(combo <= 1) combo = 1;
		if(kill_count >= bricks.len){
			win = true;	
		}
	}
	return 0;
}