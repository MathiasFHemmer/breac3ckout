module entities::core;

import allocator;
import components;
import components::shapes;
import components::particles;
import systems::sound;
import systems::bricks;
import main;

struct Context{
    Pool(<Rigidbody>) 			rigidbody_pool;
    Pool(<Shape>)				shape_pool;
    Pool(<Puck>)				puck_pool;
    Pool(<Emitter>)				emitter_pool;
    Pool(<Particle>)			particle_pool;
    Pool(<Brick>)				brick_pool;
    Pool(<Rigidbody>)			brick_rigidbody_pool;
    Pool(<components::Transform>)			transform_pool;
    SlowTime					slow_time;
    Player						player;
    Score						score;
    SoundManager				sound_manager;
    LevelManager				level_manager;
}

fn void Context.init(&self){
    self.emitter_pool.init(300);
	self.particle_pool.init(10000);
	self.puck_pool.init(500);
	self.rigidbody_pool.init(5000);
	self.shape_pool.init(5000);

    self.sound_manager.load_sound_pool("pop", "resources/pop.ogg", 30);
    self.setup_initial_entites();
}

fn void Context.setup_initial_entites(&self) @private{
    	// player
	Shape shape;
	shape.dimensions = {64, 24};
	self.player = {
		self.rigidbody_pool.new({
			0, float.typeid,
			float[<2>]{ (int)((double)main::WINDOWS_WIDTH * 0.5), (int)((double)main::WINDOWS_HEIGHT * 0.85)},
			{800,0},
			0
		}),
		self.shape_pool.new(shape)
	};

	self.slow_time = SlowTime{false, 4.0, 0.0, 0.35, 1.0, false, 0.0, 2.0};
	
	//Puck Setup
	self.puck_pool.new({
		self.rigidbody_pool.new({
			0, Puck.typeid,
			float[<2>]{(float)(main::WINDOWS_WIDTH/2), (float)(main::WINDOWS_HEIGHT-150)},
			{256,-1024},
			0
		}),
		self.shape_pool.new({3})
	});

	//UI
	self.score = {
		self.transform_pool.new({{(float)main::WINDOWS_WIDTH/2, (float)main::WINDOWS_HEIGHT * 0.90}, 0}),
		0, 0, 1, 0
	};

	self.level_manager.update_level();
	systems::bricks::spawn_initial_bricks(&self.brick_rigidbody_pool, &self.brick_pool, &self.shape_pool, {32, 12}, {self.level_manager.level.rows, self.level_manager.level.columns});
}