module components;

import raylib5::rl;

struct Brick{
    bool    is_alive;
    char    lives;
    usz     rigidbody_idx;
    usz     anim_rotation_idx;
}

const Color[] BRICKS_COLOR = {
    rl::WHITE,
    rl::GREEN,
    rl::BLUE
};