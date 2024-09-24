module components::particles;
import components::tween::core;

struct ParticlePositionOverLifetime{
    float[<2>] start_position;
    float[<2>] end_position;
    TweenType curve;
}