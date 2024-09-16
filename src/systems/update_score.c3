module systems;

import std::math;
import entities;

fn void update_score(Score* score, double dt){
    score.combo = score.combo - score.combo * 0.1 * (float)dt;
    score.combo_bonus = (float)std::math::pow(2, score.combo);
	if(score.combo <= 1) score.combo = 1;
}