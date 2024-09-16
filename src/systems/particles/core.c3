module systems::particles;

import allocator;
import std::collections::list;
import components::particles;

def EmitterPool = Pool(<Emitter>);
def ParticlePool = Pool(<Particle>);
def IdList = List(<usz>);