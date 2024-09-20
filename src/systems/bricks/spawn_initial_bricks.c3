module systems::bricks;

import allocator;
import components;
import main;
import std::io;
import collision;

fn void spawn_initial_bricks(
    Pool(<Rigidbody>)* bricks_rigidbody_pool, 
    Pool(<Brick>)* bricks_pool, 
    Pool(<Shape>)* shape_pool_handler, 
    float[<2>] brick_dimensions, 
    usz[<2>] array_dimension, 
    Pool(<AnimateShapeRect>)* animation_pool)
{
    float xSpacing = 0;
	float ySpacing = 0;
	float totalXSpaceing = ((array_dimension.x * (brick_dimensions.x + xSpacing)) - xSpacing) / 2;
	float totalYSpaceing = ((array_dimension.y * (brick_dimensions.y + ySpacing)) - ySpacing) / 2;

	for(usz i = 0; i < array_dimension.x*array_dimension.y; i++){
		usz line 	= i / array_dimension.x;
		usz column 	= i % array_dimension.x;
		usz index 	= array_dimension.x*line + column;
		float posX 	= (main::WINDOWS_WIDTH / 2 - totalXSpaceing + (column * (brick_dimensions.x + xSpacing)));
		float posY 	= (main::WINDOWS_HEIGHT / 4 - totalYSpaceing + (line * (brick_dimensions.y + ySpacing)));
        
        Shape shape;
        shape.dimensions = {
            brick_dimensions.x, brick_dimensions.y
        };
        usz total = array_dimension.x*array_dimension.y;

        float c = (float)index/(float)total * 200 + 55;
        float lives = 1;//(float)index/(float)total * 10;
        usz shape_id = shape_pool_handler.get_next_id();
        bricks_pool.new({
            (char)lives, {(char)c,(char)c,(char)c,255},
            bricks_rigidbody_pool.new({
                bricks_pool.get_next_id(), Brick.typeid,
                float[<2>]{posX, posY},
                {0,0},
                0
            }),
            shape_pool_handler.new(shape),
            animation_pool.new({
                {false, false, 1, 0, TweenType.EASYOUTELASTIC, 0},
				shape_id, {brick_dimensions.x, brick_dimensions.y}, {brick_dimensions.x, brick_dimensions.y}
            })
        });		
	}
}