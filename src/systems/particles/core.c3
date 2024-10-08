module systems::particles;

import std::collections::list;
import std::math::random;
import std::collections::map;
import allocator;
import entities::core;
import components::particles;
import systems::particles::behaviour;

def IdList = List(<usz>);

IdList to_delete;
DefaultRandom rand;

def ParticleComponentHandler = fn void(ParticleContext* context, Particle* p, usz id, double dt);
def ParticleComponentLUT = HashMap(<typeid, ParticleComponentHandler>);

def EmitterComponentHandler = fn void(ParticleContext* context, Emitter* e, usz id, double dt);
def EmitterComponentLUT = HashMap(<typeid, EmitterComponentHandler>);

ParticleComponentLUT particle_lut;
EmitterComponentLUT emitter_lut;

fn void setup() @init{
    to_delete = *IdList{}.new_init(500);

    particle_lut = *ParticleComponentLUT{}.new_init_with_key_values(
        ParticleScaleOverLifetime.typeid,   &systems::particles::behaviour::update_scale_over_lifetime,
        ParticleColorOverLifetime.typeid,   &systems::particles::behaviour::update_color_over_lifetime,
        ParticleGravity.typeid,             &systems::particles::behaviour::update_gravity,
        ParticlePositionOverLifetime.typeid,&systems::particles::behaviour::update_position_over_lifetime,
    );

    emitter_lut = *EmitterComponentLUT{}.new_init_with_key_values(
        EmitterSingleTrigger.typeid, &systems::particles::emitter::behaviour::update_single_trigger,
        EmitterTriggerAfterInterval.typeid, &systems::particles::emitter::behaviour::update_trigger_after_interval,
        EmitterTriggerOverTime.typeid, &systems::particles::emitter::behaviour::update_trigger_over_time
    );
}