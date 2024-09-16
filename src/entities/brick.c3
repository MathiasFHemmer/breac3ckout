module components;

import raylib5::rl;

struct Brick{
    char    lives;
    usz     rigidbody_idx;
    usz     shapebox_idx;
}

const Color[] BRICKS_COLOR = {
    rl::WHITE,
    rl::GREEN,
    rl::BLUE
};