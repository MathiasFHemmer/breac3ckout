module commands::particles;

import raylib5;
import entities::core;
import components::particles;
import std::io;
import componens::particles::properties;

fn void spawn_brick_break_emitter(ParticleContext* context, float[<2>] position, ParticleAmountType type, EmiterAmountData amount, ParticlePositionType  position_type, EmiterPositionData position_data){
    EmitterComponents components = *EmitterComponents{}.new_init_with_key_values(
        EmitterSingleTrigger.typeid, context.single_trigger_pool.new ({true})
    );

    context.emiter_pool.new({
        true,
        position,
        0,1,components,
        type, amount, position_type, position_data
    });
}