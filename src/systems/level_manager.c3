module systems;

import entities;
import std::math;

struct LevelManager {
    Level level;
    bool finished;
}

fn void LevelManager.update_level(&self){
    self.level.dificulty_scale += 1;
    self.level.rows = (usz)(math::clamp(self.level.dificulty_scale, 0, 20));
    self.level.columns = (usz)(math::clamp(self.level.dificulty_scale*2, 0, 40));
    self.level.current_bricks = (int)(self.level.rows * self.level.columns);
}