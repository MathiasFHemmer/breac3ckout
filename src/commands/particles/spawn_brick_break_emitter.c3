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
        &create_components,
        type, amount, position_type, position_data
    });
}

fn void create_components(ParticleContext* context, Emitter* e, Particle* p){
    ParticleComponents* components = &p.components;

    components.set(ParticleScaleOverLifetime.typeid,
        context.particle_scale_over_lifetime_pool.new({
            1, 0
        })
    );
    components.set(ParticleColorOverLifetime.typeid,
        context.particle_color_over_lifetime_pool.new({
            rl::RED, rl::BLUE
        })
    );
    components.set(ParticleGravity.typeid,
        context.particle_gravity_pool.new({
            500
        })
    );
}