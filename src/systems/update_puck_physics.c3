module systems;

import components;
import std::collections;
import entities;
import main;
import components::particles;
import std::io;
import std::math;
import allocator;
import collision;
import systems::sound;
import commands::particles;
import componens::particles::properties;

def IdList = List(<usz>) @private;

IdList bricks_to_delete;
IdList pucks_to_delete;

fn void update_puck_physics(
    Pool(<Puck>)* puck_pool_handler, 
    Pool(<Brick>)* brick_pool_handler, 
    Pool(<Rigidbody>)* brick_rigidbody_pool_handler,
    Player player,
    Pool(<Rigidbody>)* rigidbody_pool_handler, 
    Pool(<Shape>)* shape_pool_handler,
    ParticleContext* particle_context,
    Score* score,
    SlowTime slow_time,
    SoundManager sound_manager,
    LevelManager* level_manager,
    Pool(<AnimateShapeRect>)* animate_shape_rect_handler,
    double dt){

    for(usz i = 0; i < puck_pool_handler.active_len; i++){
        Puck puck = puck_pool_handler.entity_pool[puck_pool_handler.active_pool[i]];
        
        // Bricks    
        for(usz j = 0; j < brick_pool_handler.active_len; j++){
            if(rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].position.y > main::WINDOWS_HEIGHT*0.75){
                //io::printfn("Skipping");
                break;
            }
            Brick* brick = &brick_pool_handler.entity_pool[brick_pool_handler.active_pool[j]];
            if (try manifold = collision::checkCircleOnRectCollision(
                rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].position, 
                shape_pool_handler.entity_pool[puck.shape_idx].radius, 
                brick_rigidbody_pool_handler.entity_pool[brick.rigidbody_idx].position, 
                shape_pool_handler.entity_pool[brick.shapebox_idx])){
                (&rigidbody_pool_handler.entity_pool[puck.rigidbody_idx]).position += manifold.penetration;
                switch(manifold.side){
                    case CollisionSide.BOTTOM:
                    case CollisionSide.TOP:
                        rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].velocity.y *= -1;
                    case CollisionSide.LEFT:
                    case CollisionSide.RIGHT:
                        rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].velocity.x *=-1;
                }
                
                (&animate_shape_rect_handler.entity_pool[brick.animate_shape_rect_idx]).initial_value = animate_shape_rect_handler.entity_pool[brick.animate_shape_rect_idx].target_value;
                (&animate_shape_rect_handler.entity_pool[brick.animate_shape_rect_idx]).target_value *= 0.5;
                (&animate_shape_rect_handler.entity_pool[brick.animate_shape_rect_idx]).is_playing = true;
                
                sound_manager.play_sound_from_pool("pop");
                brick.lives -= 1;
                if(brick.lives == 0){
                    score.combo = std::math::clamp(++score.combo, 0, 5);
                    score.combo_bonus = (int)std::math::pow(2, score.combo);
                    score.points += score.combo_bonus;
                    score.kill_count++;
                    level_manager.level.current_bricks--;
                    commands::particles::spawn_brick_break_emitter(particle_context, rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].position, ParticleAmountType.RANDOM_RANGE, {.range = {5,10}});
                    bricks_to_delete.push(brick_pool_handler.active_pool[j]);
                }else{
                    commands::particles::spawn_brick_break_emitter(particle_context, rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].position, ParticleAmountType.FIXED, {.fixed = 2});
                }
            }
	    }

        // Player
        if(try manifold = collision::checkCircleOnRectCollision(
            rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].position,
            shape_pool_handler.entity_pool[puck.shape_idx].radius, 
            rigidbody_pool_handler.entity_pool[player.rigidbody_idx].position, 
            shape_pool_handler.entity_pool[player.shape_idx])){
			//TODO: Handle collision penetration
            (&rigidbody_pool_handler.entity_pool[puck.rigidbody_idx]).position += manifold.penetration;
			switch(manifold.side){
				case CollisionSide.BOTTOM:
				case CollisionSide.TOP:
					rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].velocity.y *= -1;
				case CollisionSide.LEFT:
				case CollisionSide.RIGHT:
					rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].velocity.x *= -1;
			}
		}

        //Screen Limits
        // LEFT
        if(rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].position.x - shape_pool_handler.entity_pool[puck.shape_idx].radius <= 0){
            rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].position.x = shape_pool_handler.entity_pool[puck.shape_idx].radius;
            rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].velocity.x *= -1;
        }
        // RIGHT
        if(rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].position.x + shape_pool_handler.entity_pool[puck.shape_idx].radius >= main::WINDOWS_WIDTH){
            rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].position.x = main::WINDOWS_WIDTH - shape_pool_handler.entity_pool[puck.shape_idx].radius;
		    rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].velocity.x *= -1;
		}

        // UP
        if(rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].position.y - shape_pool_handler.entity_pool[puck.shape_idx].radius <= 0){
            rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].position.y = shape_pool_handler.entity_pool[puck.shape_idx].radius;
            rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].velocity.y *= -1;
        }
        if(rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].position.y + shape_pool_handler.entity_pool[puck.shape_idx].radius >= main::WINDOWS_HEIGHT){ 
            //rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].velocity.y *= -1;
            pucks_to_delete.push(puck_pool_handler.active_pool[i]);
            score.combo = 1;
            score.combo_bonus = 1;
        }

        (&rigidbody_pool_handler.entity_pool[puck.rigidbody_idx]).position +=  rigidbody_pool_handler.entity_pool[puck.rigidbody_idx].velocity * (float[<2>])(slow_time.value * dt);
    };

    foreach(dto: bricks_to_delete){
        animate_shape_rect_handler.delete(animate_shape_rect_handler.active_pool_map[brick_pool_handler.entity_pool[dto].animate_shape_rect_idx]);
        brick_rigidbody_pool_handler.delete(brick_rigidbody_pool_handler.active_pool_map[brick_pool_handler.entity_pool[dto].rigidbody_idx]);
        shape_pool_handler.delete(shape_pool_handler.active_pool_map[brick_pool_handler.entity_pool[dto].shapebox_idx]);
        brick_pool_handler.delete(brick_pool_handler.active_pool_map[dto]);
    }
    bricks_to_delete.clear();

    foreach(dto : pucks_to_delete){
        rigidbody_pool_handler.delete(rigidbody_pool_handler.active_pool_map[puck_pool_handler.entity_pool[dto].rigidbody_idx]);
        shape_pool_handler.delete(shape_pool_handler.active_pool_map[puck_pool_handler.entity_pool[dto].shape_idx]);
        puck_pool_handler.delete(puck_pool_handler.active_pool_map[dto]);
    }
    pucks_to_delete.clear();
}