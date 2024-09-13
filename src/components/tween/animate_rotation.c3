module components::tween;

struct AnimateRotation{
    inline Animation animation;
    usz rigidbody_idx;
    float initial_value;
    float target_value;
}