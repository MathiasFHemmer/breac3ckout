module commands::particles::defaults_spawners;

import entities::core;
import components::particles;
import raylib5::rl;
import std::collections::map;

def SpawnCommand = fn void (ParticleContext* context, Emitter* e);

def EmitterTriggerTypeLUT = HashMap(<typeid, SpawnCommand>);
EmitterTriggerTypeLUT emitter_trigger_lut;

fn void setup() @init{
    emitter_trigger_lut = *EmitterTriggerTypeLUT{}.new_init_with_key_values(
        BurstTriggerData.typeid, &spawn_burst
    );
}