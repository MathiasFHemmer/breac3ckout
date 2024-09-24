module entities;

import components::particles;
import componens::particles::properties;
import entities::core;
import raylib5;
import components::tween::core;

struct SlowTime{
    bool is_active;
    double duration_max;
    double duration_current;
    double scale;
    double value;

    bool is_burnout;
    double burnout_current;
    double burnout_max;

    usz emitter_idx;
}

fn void SlowTime.init(&self, ParticleContext* particle_context){
    EmitterComponents components = *EmitterComponents{}.new_init_with_key_values(
    EmitterTriggerOverTime.typeid, particle_context.emitter_trigger_over_time_pool.new ({0.1, 5, 0})
    );

    self.emitter_idx = particle_context.emiter_pool.new({
        false,
        {0,-100},
        0,-1,components,
        &create_components,
        ParticleAmountType.FIXED, {.fixed = 3}, ParticlePositionType.RANDOM_IN_CIRCLE_RADIUS, {.random_in_circle_radius=100}
    });
}

fn void SlowTime.start(SlowTime* self){
    self.is_active = true;
}

fn void SlowTime.stop(SlowTime* self){
    self.value = 1;
    self.is_active = false;
}

fn void create_components(ParticleContext* context, Emitter* e, Particle* p){
    p.components.set(ParticleScaleOverLifetime.typeid,
        context.particle_scale_over_lifetime_pool.new({
            1, 0
        })
    );
    p.components.set(ParticleColorOverLifetime.typeid,
        context.particle_color_over_lifetime_pool.new({
            rl::YELLOW, rl::BLUE
        })
    );
    p.components.set(ParticlePositionOverLifetime.typeid,
        context.particle_position_over_lifetime_pool.new({
            p.rigidbody.position, (e.position + {0, 0}), TweenType.EASYOUTELASTIC
        })
    );
}