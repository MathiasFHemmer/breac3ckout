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
import allocator;


// Data
Pool(<Rigidbody>) 			rigidbody_pool;
Pool(<Shape>)				shape_pool;
Pool(<Puck>)				puck_pool;
List(<AnimateRotation>)		anim_rotation_pool;
List(<AnimatePosition>)		pos_animation_pool;
Pool(<Emitter>)				emitter_pool;
Pool(<Particle>)			particle_pool;
Pool(<Brick>)				brick_pool;
Pool(<Rigidbody>)			brick_rigidbody_pool;
Pool(<components::Transform>)			transform_pool;
SlowTime					slow_time;
Player						player;
Score						score;

// Config
const CInt WINDOWS_HEIGHT 	= 600;
const CInt WINDOWS_WIDTH 	= 800;
const float[<2>] 	BRICK_DIMENSION	= {64, 24};

// Sounds
Sound[4] sound_fx   				= {};
int current_paddle_hit_fx 			= 0;
Sound[10] paddle_hit_audio_channel 	= {};

fn void drawScore(){
	ZString score_text = std::core::string::tformat_zstr("SCORE: %d", score.points);
	Vector2 score_text_position = {transform_pool.entity_pool[score.transform_idx].position.x, transform_pool.entity_pool[score.transform_idx].position.y};
	ZString combo_text = std::core::string::tformat_zstr("COMBO: %2.1f (+ %d)", score.combo, score.combo_bonus);
	//rl::drawTextPro(rl::getFontDefault(), score_text, score_text_position, {(float)rl::measureText(score_text, 18)/2,0}, transform_pool.entity_pool[score.transform_idx].rotation, 18, 2, rl::WHITE);
	rl::drawText(score_text, WINDOWS_WIDTH/2 - rl::measureText(score_text, 18)/2, WINDOWS_HEIGHT - 60, 18, rl::WHITE);
	rl::drawText(combo_text, WINDOWS_WIDTH/2 - rl::measureText(combo_text, 18)/2, WINDOWS_HEIGHT - 40, 18, rl::WHITE);
}

fn void processInput(){
	Rigidbody* rb = &rigidbody_pool.entity_pool[player.rigidbody_idx];
	Shape* shape = &shape_pool.entity_pool[player.shape_idx];

	// Handle Paddle Movement
	if(rl::isKeyDown(rl::KEY_LEFT) && rb.position.x - shape.dimensions.x/2  > 0){
		rb.position -= rb.velocity * rl::getFrameTime();
	};
	if(rl::isKeyDown(rl::KEY_RIGHT) && rb.position.x + shape.dimensions.x/2 < WINDOWS_WIDTH){
		rb.position += rb.velocity * rl::getFrameTime();
	};

	if(rl::isKeyDown(rl::KEY_W)){
		if(!rl::isSoundPlaying(sound_fx[2])) rl::playSound(sound_fx[2]);
		float vel_x = (float)rl::getTime() * 100 % 512 - 256;
		puck_pool.new({
			rigidbody_pool.new({
				0, Puck.typeid,
				float[<2>]{(float)(WINDOWS_WIDTH/2), (float)(WINDOWS_HEIGHT-50)},
				{vel_x,-256},
				0
			}),
			shape_pool.new({5})
		});
	}
	
	if(rl::isKeyReleased(rl::KEY_W)){
		rl::stopSound(sound_fx[2]);
		rl::playSound(sound_fx[3]);
	}

	if(rl::isKeyPressed(rl::KEY_SPACE)){
		slow_time.start();
	}
	if (rl::isKeyReleased(rl::KEY_SPACE)){
		slow_time.stop();
	};
	
	if(rl::isMouseButtonDown(MouseButton.LEFT)){
				emitter_pool.new({
				true,
				float[<2>]{rl::getMouseX(), rl::getMouseY()},
				true,
				rl::RED
			});
	}
	
}

fn void updateUI(){
	rl::beginDrawing();
		rl::clearBackground(rl::BLACK);
		rl::drawFPS(0, 0);
		drawScore();

		//Player
		Rectangle rec = {
			rigidbody_pool.entity_pool[player.rigidbody_idx].position.x,
			rigidbody_pool.entity_pool[player.rigidbody_idx].position.y,
			shape_pool.entity_pool[player.shape_idx].dimensions.x,
			shape_pool.entity_pool[player.shape_idx].dimensions.y
			};
		rl::drawRectanglePro(rec, {shape_pool.entity_pool[player.shape_idx].dimensions.x/2, shape_pool.entity_pool[player.shape_idx].dimensions.y/2}, 0, rl::WHITE);

		//Pucks
		for(usz i = 0; i < puck_pool.active_pool.len(); i++){
			Puck puck = puck_pool.entity_pool[puck_pool.active_pool[i]];
			rl::drawCircle(
				(int)rigidbody_pool.entity_pool[puck.rigidbody_idx].position.x, 
				(int)rigidbody_pool.entity_pool[puck.rigidbody_idx].position.y, 
				shape_pool.entity_pool[puck.shape_idx].radius, rl::WHITE);
		};

		//Bricks
		for(usz i = 0; i < brick_pool.active_pool.len(); i++){
			Brick brick = brick_pool.entity_pool[brick_pool.active_pool[i]];
			Rectangle rect = {
				brick_rigidbody_pool.entity_pool[brick.rigidbody_idx].position.x,
				brick_rigidbody_pool.entity_pool[brick.rigidbody_idx].position.y,
				shape_pool.entity_pool[brick.shapebox_idx].dimensions.x,
				shape_pool.entity_pool[brick.shapebox_idx].dimensions.y
			};
			rl::drawRectanglePro(rect, 
				{shape_pool.entity_pool[brick.shapebox_idx].dimensions.x/2,shape_pool.entity_pool[brick.shapebox_idx].dimensions.y/2}, 
				0, 
				brick.color);
		};
		
		//Particles
		for(int i = 0; i < particle_pool.active_pool.len(); i++){
			Particle particle = particle_pool.entity_pool[particle_pool.active_pool[i]];
			rl::drawCircle((int)(particle.rigidbody.position.x + particle.spawn_position.x), (int)(particle.rigidbody.position.y + particle.spawn_position.y), particle.shape.radius, particle.color);
		};

		// User Interface
		Rectangle power_bar = {WINDOWS_WIDTH/2 -25, WINDOWS_HEIGHT-10, 50, 5};
		Rectangle power_bar_bg = {WINDOWS_WIDTH/2 -27, WINDOWS_HEIGHT-12, 54, 9};
		Color bar_color = slow_time.is_burnout ? rl::RED : rl::GREEN;
		power_bar.width = (float)(power_bar.width * slow_time.duration_current/slow_time.duration_max);
		rl::drawRectanglePro(power_bar_bg, {0, 0}, 0, rl::WHITE);
		rl::drawRectanglePro(power_bar, {0, 0}, 0, bar_color);
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
		rl::loadSound("resources/minigun.ogg"),
		rl::loadSound("resources/minigun_stop.ogg"),
	};
	for(int x = 0; x < paddle_hit_audio_channel.len; x++) paddle_hit_audio_channel[x] = rl::loadSoundAlias(sound_fx[0]);

	// Init components
	//UI
	score = {
		transform_pool.new({{(float)WINDOWS_WIDTH/2, (float)WINDOWS_HEIGHT * 0.90}, 0}),
		0, 0, 1, 0
	};

	// player
	Shape shape;
	shape.dimensions = {64, 24};
	player = {
		rigidbody_pool.new({
			0, float.typeid,
			float[<2>]{ (int)((double)WINDOWS_WIDTH * 0.5), (int)((double)WINDOWS_HEIGHT * 0.85)},
			{800,0},
			0
		}),
		shape_pool.new(shape)
	};

	slow_time = SlowTime{false, 4.0, 0.0, 0.35, 1.0, false, 0.0, 2.0};
	
	//Puck Setup
	puck_pool.new({
		rigidbody_pool.new({
			0, Puck.typeid,
			float[<2>]{(float)(WINDOWS_WIDTH/2), (float)(WINDOWS_HEIGHT-150)},
			{256,-256},
			0
		}),
		shape_pool.new({5})
	});

	systems::bricks::spawn_initial_bricks(&brick_rigidbody_pool, &brick_pool, &shape_pool, {20, 10}, {32,24});

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
		systems::update_score(&score, rl::getFrameTime());
		systems::update_slow_time(&slow_time, rl::getFrameTime());
		//systems::tween::update_animate_rotation(anim_rotation_pool, rigidbody_pool, rl::getFrameTime());
		//systems::tween::update_animate_position(pos_animation_pool, rigidbody_pool, rl::getFrameTime());
		
		processInput();
		
		systems::update_puck_physics(&puck_pool, &brick_pool, &brick_rigidbody_pool, player, &rigidbody_pool, &shape_pool, &emitter_pool, &score, slow_time, rl::getFrameTime());
		
		updateUI();
		
	}
	return 0;
}