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

// Data
Context context;

// Config
const CInt WINDOWS_HEIGHT 	= 600;
const CInt WINDOWS_WIDTH 	= 800;
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
		case(rl::isKeyDown(rl::KEY_LEFT) && rb.position.x - shape.dimensions.x/2 > 0): rb.position -= rb.velocity * rl::getFrameTime();
		case(rl::isKeyDown(rl::KEY_RIGHT) && rb.position.x + shape.dimensions.x/2 < WINDOWS_WIDTH): rb.position += rb.velocity * rl::getFrameTime();
	};
	
	if(rl::isKeyDown(rl::KEY_W)){
		float vel_x = (float)rl::getTime() * 100 % 512 - 256;
		context.puck_pool.new({
			context.rigidbody_pool.new({
				0, Puck.typeid,
				float[<2>]{(float)(WINDOWS_WIDTH/2), (float)(WINDOWS_HEIGHT-50)},
				{vel_x,-1024},
				0
			}),
			context.shape_pool.new({3})
		});
	}

	if(rl::isKeyPressed(rl::KEY_SPACE)){
		context.slow_time.start();
	}
	if (rl::isKeyReleased(rl::KEY_SPACE)){
		context.slow_time.stop();
	};
	
	if(rl::isMouseButtonDown(MouseButton.LEFT)){
				context.emitter_pool.new({
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
			context.rigidbody_pool.entity_pool[context.player.rigidbody_idx].position.x,
			context.rigidbody_pool.entity_pool[context.player.rigidbody_idx].position.y,
			context.shape_pool.entity_pool[context.player.shape_idx].dimensions.x,
			context.shape_pool.entity_pool[context.player.shape_idx].dimensions.y
			};
		rl::drawRectanglePro(rec, {context.shape_pool.entity_pool[context.player.shape_idx].dimensions.x/2, context.shape_pool.entity_pool[context.player.shape_idx].dimensions.y/2}, 0, rl::WHITE);

		//Pucks
		for(usz i = 0; i < context.puck_pool.active_pool.len(); i++){
			Puck puck = context.puck_pool.entity_pool[context.puck_pool.active_pool[i]];
			rl::drawCircle(
				(int)context.rigidbody_pool.entity_pool[puck.rigidbody_idx].position.x, 
				(int)context.rigidbody_pool.entity_pool[puck.rigidbody_idx].position.y, 
				context.shape_pool.entity_pool[puck.shape_idx].radius, rl::WHITE);
		};

		//Bricks
		for(usz i = 0; i < context.brick_pool.active_pool.len(); i++){
			Brick brick = context.brick_pool.entity_pool[context.brick_pool.active_pool[i]];
			Rectangle rect = {
				context.brick_rigidbody_pool.entity_pool[brick.rigidbody_idx].position.x,
				context.brick_rigidbody_pool.entity_pool[brick.rigidbody_idx].position.y,
				context.shape_pool.entity_pool[brick.shapebox_idx].dimensions.x,
				context.shape_pool.entity_pool[brick.shapebox_idx].dimensions.y
			};
			rl::drawRectanglePro(rect, 
				{context.shape_pool.entity_pool[brick.shapebox_idx].dimensions.x/2,context.shape_pool.entity_pool[brick.shapebox_idx].dimensions.y/2}, 
				0, 
				brick.color);
		};
		
		//Particles
		for(int i = 0; i < context.particle_pool.active_pool.len(); i++){
			Particle particle = context.particle_pool.entity_pool[context.particle_pool.active_pool[i]];
			rl::drawCircle((int)(particle.rigidbody.position.x + particle.spawn_position.x), (int)(particle.rigidbody.position.y + particle.spawn_position.y), particle.shape.radius, particle.color);
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
	rl::initWindow(WINDOWS_WIDTH, WINDOWS_HEIGHT, "Brick Breaker");
	defer rl::closeWindow();
	rl::initAudioDevice();
	defer rl::closeAudioDevice();


	context.init();
	


	bool win = false;
	while(!rl::windowShouldClose()){

		if(context.level_manager.level.current_bricks <= 0 ){
			context.level_manager.update_level();
			systems::bricks::spawn_initial_bricks(&context.brick_rigidbody_pool, &context.brick_pool, &context.shape_pool, {32, 12}, {context.level_manager.level.rows, context.level_manager.level.columns});
		}

		systems::particles::update_emitter(&context.emitter_pool, &context.particle_pool);		
		systems::particles::update_particle(&context.particle_pool, rl::getFrameTime());
		systems::update_score(&context.score, rl::getFrameTime());
		systems::update_slow_time(&context.slow_time, rl::getFrameTime());
				
		processInput();
		
		systems::update_puck_physics(&context.puck_pool, &context.brick_pool, &context.brick_rigidbody_pool, context.player, &context.rigidbody_pool, &context.shape_pool, &context.emitter_pool, &context.score, context.slow_time, context.sound_manager, &context.level_manager, rl::getFrameTime());
		
		updateUI();
		
	}
	return 0;
}