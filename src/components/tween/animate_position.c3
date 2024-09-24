module components::tween;

struct AnimatePosition{
    inline Animation animation;
    usz rigidbody_idx;
    float[<2>] initial_value;
    float[<2>] target_value;
}