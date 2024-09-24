import version;
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
import systems::sound;
import commands::particles;

// Data
Context context;
ParticleContext particle_context;

// Config
const CInt WINDOWS_HEIGHT 	= 920;
const CInt WINDOWS_WIDTH 	= 1280;
const float[<2>] 	BRICK_DIMENSION	= {64, 24};

fn void drawScore(){
	ZString score_text = std::core::string::tformat_zstr("SCORE: %d", context.score.points);
	Vector2 score_text_position = {context.transform_pool.entity_pool[context.score.transform_idx].position.x, context.transform_pool.entity_pool[context.score.transform_idx].position.y};
	ZString combo_text = std::core::string::tformat_zstr("COMBO: %2.1f (+ %d)", context.score.combo, context.score.combo_bonus);
	rl::drawText(score_text, WINDOWS_WIDTH/2 - rl::measureText(score_text, 18)/2, WINDOWS_HEIGHT - 60, 18, rl::WHITE);
	rl::drawText(combo_text, WINDOWS_WIDTH/2 - rl::measureText(combo_text, 18)/2, WINDOWS_HEIGHT - 40, 18, rl::WHITE);
}

fn void processInput(){
	Rigidbody* rb = &context.rigidbody_pool.entity_pool[context.player.rigidbody_idx];
	Shape* shape = &context.shape_pool.entity_pool[context.player.shape_idx];

	// Handle Paddle Movement
	switch{
		case(rl::isKeyDown(rl::KEY_A) && rb.position.x - shape.dimensions.x/2 > 0): rb.position -= rb.velocity * rl::getFrameTime();
		case(rl::isKeyDown(rl::KEY_D) && rb.position.x + shape.dimensions.x/2 < WINDOWS_WIDTH): rb.position += rb.velocity * rl::getFrameTime();
	};
	
	if(rl::isKeyDown(rl::KEY_W)){
		float vel_x = (float)rl::getTime() * 1000 % 1024 - 512;
		context.puck_pool.new({
			context.rigidbody_pool.new({
				float[<2>]{(float)(WINDOWS_WIDTH/2), (float)(WINDOWS_HEIGHT-50)},
				{vel_x,-1024},
				0
			}),
			context.shape_pool.new({3})
		});
	}

	if(rl::isKeyDown(rl::KEY_S)){
		(&context.shape_pool.entity_pool[context.player.shape_idx]).dimensions = {512, 24};
	}else{
		(&context.shape_pool.entity_pool[context.player.shape_idx]).dimensions = {64, 24};
	}

	if(rl::isKeyPressed(rl::KEY_SPACE)){
		particle_context.emiter_pool.entity_pool[context.slow_time.emitter_idx].active = true;
		context.slow_time.start();
	}
	if (rl::isKeyReleased(rl::KEY_SPACE)){
		particle_context.emiter_pool.entity_pool[context.slow_time.emitter_idx].active = false;
		context.slow_time.stop();
	};
}

fn void updateUI(){
	rl::beginDrawing();
		rl::clearBackground(rl::BLACK);
		rl::drawFPS(0, 0);
		drawScore();

		//Player
		Rectangle rec = {
			context.rigidbody_pool.entity_pool[context.player.rigidbody_idx].position.x,
			context.rigidbody_pool.entity_pool[context.player.rigidbody_idx].position.y,
			context.shape_pool.entity_pool[context.player.shape_idx].dimensions.x,
			context.shape_pool.entity_pool[context.player.shape_idx].dimensions.y
			};
		rl::drawRectanglePro(rec, {context.shape_pool.entity_pool[context.player.shape_idx].dimensions.x/2, context.shape_pool.entity_pool[context.player.shape_idx].dimensions.y/2}, 0, rl::WHITE);

		//Pucks
		for(usz i = 0; i < context.puck_pool.active_len; i++){
			Puck puck = context.puck_pool.entity_pool[context.puck_pool.active_pool[i]];
			rl::drawCircle(
				(int)context.rigidbody_pool.entity_pool[puck.rigidbody_idx].position.x, 
				(int)context.rigidbody_pool.entity_pool[puck.rigidbody_idx].position.y, 
				context.shape_pool.entity_pool[puck.shape_idx].radius, rl::WHITE);
		};

		//Bricks
		for(usz i = 0; i < context.brick_pool.active_len; i++){
			Brick brick = context.brick_pool.entity_pool[context.brick_pool.active_pool[i]];
			Rectangle rect = {
				context.brick_rigidbody_pool.entity_pool[brick.rigidbody_idx].position.x,
				context.brick_rigidbody_pool.entity_pool[brick.rigidbody_idx].position.y,
				context.shape_pool.entity_pool[brick.shapebox_idx].dimensions.x,
				context.shape_pool.entity_pool[brick.shapebox_idx].dimensions.y
			};
			rl::drawRectanglePro(rect, 
				{context.shape_pool.entity_pool[brick.shapebox_idx].dimensions.x/2,context.shape_pool.entity_pool[brick.shapebox_idx].dimensions.y/2}, 
				context.brick_rigidbody_pool.entity_pool[brick.rigidbody_idx].rotation, 
				brick.color);
		};
		
		//Particles
		for(int i = 0; i < particle_context.particle_pool.active_len; i++){
			Particle particle = particle_context.particle_pool.entity_pool[particle_context.particle_pool.active_pool[i]];
			rl::drawCircle((int)(particle.rigidbody.position.x), (int)(particle.rigidbody.position.y), particle.shape.radius * particle.scale, particle.color);
		};

		// User Interface
		Rectangle power_bar = {WINDOWS_WIDTH/2 -25, WINDOWS_HEIGHT-10, 50, 5};
		Rectangle power_bar_bg = {WINDOWS_WIDTH/2 -27, WINDOWS_HEIGHT-12, 54, 9};
		Color bar_color = context.slow_time.is_burnout ? rl::RED : rl::GREEN;
		power_bar.width = (float)(power_bar.width * context.slow_time.duration_current/context.slow_time.duration_max);
		rl::drawRectanglePro(power_bar_bg, {0, 0}, 0, rl::WHITE);
		rl::drawRectanglePro(power_bar, {0, 0}, 0, bar_color);
	rl::endDrawing();
}

fn int main(String[] args) //@winmain
{


	rl::initWindow(WINDOWS_WIDTH, WINDOWS_HEIGHT, string::tformat("Brick Breaker - %s v.%s", version::BUILD_TIMESTAMP, version::BUILD_VERSION));
	defer rl::closeWindow();
	rl::initAudioDevice();
	defer rl::closeAudioDevice();

	context.init(&particle_context);	
	
	bool win = false;
	while(!rl::windowShouldClose()){
		if(context.level_manager.level.current_bricks <= 0 ){
			context.level_manager.update_level();
			systems::bricks::spawn_initial_bricks(&context.brick_rigidbody_pool, &context.brick_pool, &context.shape_pool, {32, 12}, {context.level_manager.level.rows, context.level_manager.level.columns}, &context.animate_shape_rect_pool);
		}

		systems::particles::emitter::update_emitter(&particle_context, rl::getFrameTime());		
		systems::particles::update_particle(&particle_context, rl::getFrameTime());
		systems::update_score(&context.score, rl::getFrameTime());
		systems::update_slow_time(&context.slow_time, &context, &particle_context,  rl::getFrameTime());
		systems::tween::update_animate_rotation(&context.animate_rotation_pool, &context.brick_rigidbody_pool, rl::getFrameTime());
		systems::tween::update_animate_shape_rect(&context.animate_shape_rect_pool, &context.shape_pool, rl::getFrameTime());
				
		processInput();
		
		systems::update_puck_physics(&context.puck_pool, &context.brick_pool, &context.brick_rigidbody_pool, context.player, &context.rigidbody_pool, &context.shape_pool, &particle_context, &context.score, context.slow_time, context.sound_manager, &context.level_manager, &context.animate_shape_rect_pool, rl::getFrameTime());
		
		updateUI();
		
	}
	return 0;
}