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
