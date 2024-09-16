module components::particles;

import raylib5::rl;
import components::shapes;

struct Particle{
    float[<2>] spawn_position;
    usz emitter_idx;
    Rigidbody rigidbody;
    Shape shape;
    Color color;
    double lifetime;
    double max_lifetime;
    float start_radius;
    float end_radius;
}