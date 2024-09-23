module components::particles;

import raylib5::rl;
import components::shapes;
import entities::core;

import std::collections;

def ParticleComponents = HashMap(<typeid, usz>);

struct Particle{
    Rigidbody rigidbody;
    Shape shape;
    Color color;
    double lifetime;
    double max_lifetime;
    float scale;
    ParticleComponents components;
}

fn Particle* Particle.add_scale_over_lifetime(&self, ParticleContext* context){
    self.components.set(
        ParticleScaleOverLifetime.typeid,
        context.particle_scale_over_lifetime_pool.new({
            1, 0
        })
    );

    return self;
}

