module components::particles;

import raylib5;
import std::collections;
import commands::particles::defaults_spawners;
import componens::particles::properties;
import entities::core;

def EmitterComponents = HashMap(<typeid, usz>);
def CreateParticleComponentsHandler = fn void(ParticleContext* context, Emitter* e, Particle* p);

union EmiterAmountData{
     int fixed;
     int[<2>] range;
}

union EmiterPositionData{
     float[<2>] fixed;
     float random_inside_circle;
     float random_in_circle_radius;
}

struct Emitter{
    bool active;
    float[<2>] position;
    double lifetime;
    double max_lifetime;
    EmitterComponents components;
    
    CreateParticleComponentsHandler particle_components_handler;
    ParticleAmountType amount_type;
    EmiterAmountData amount_data;
    ParticlePositionType position_type;
    EmiterPositionData position_data;
}