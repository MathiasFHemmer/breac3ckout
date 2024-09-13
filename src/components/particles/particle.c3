module components::particles;

import raylib5::rl;
import components::shapes;

struct Particle{
    usz emitter_idx;
    Rigidbody rigidbody;
    ShapeBox shape;
    Color color;
    double lifetime;
    double max_lifetime;
    float start_radius;
    float end_radius;

}