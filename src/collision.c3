module collision;

import raylib5::rl;
import std::math;
import std::io;
import components::shapes;


struct CollisionManifold{
    CollisionSide side;
    float[<2>] penetration;
}

enum CollisionSide{
    TOP, BOTTOM, LEFT, RIGHT
}

fault CollisionFault{
    NOT_COLLIDED
}

fn CollisionManifold! checkCircleOnRectCollision(float[<2>] ball_position, float ball_radius, float[<2>] rec_position, Shape rect_shape){
    Vector2 circle = Vector2{ball_position.x, ball_position.y};
    Rectangle rec = Rectangle{rec_position.x - rect_shape.dimensions.x/2, rec_position.y - rect_shape.dimensions.y/2, rect_shape.dimensions.x, rect_shape.dimensions.y};

    //rl::drawRectangle((int)(rec.x-2), (int)(rec.y-2), (int)rec.width+4, (int)rec.height+4, {200, 25, 25, 255});

    if (rl::checkCollisionCircleRec(circle, ball_radius, rec)){
        float[<2>] nearest_axis = {
            math::max(rec.x, math::min(circle.x, rec.x + rec.width)),
            math::max(rec.y, math::min(circle.y, rec.y + rec.height))
        };

        float left  = math::abs(nearest_axis.x - rec.x);
        float right = math::abs(nearest_axis.x - (rec.x + rec.width));
        float top   = math::abs(nearest_axis.y - rec.y);
        float bottom= math::abs(nearest_axis.y - (rec.y + rec.height));

        float[<2>] distance = (float[<2>]{ball_position.x - nearest_axis.x, ball_position.y - nearest_axis.y});
        float distance_length = distance.length(); 
        float penetration_depth = ball_radius - distance_length;

        float[<2>] penetration = {0,0};
        if(distance_length != 0 && penetration_depth != 0){
            penetration = distance / (distance_length * penetration_depth);
        }else{
            penetration = {0, penetration_depth};
        }

        switch{
            case(left   < ball_radius && left < top && left < bottom):
                return {CollisionSide.LEFT, penetration};
            case(right  < ball_radius && right < top && right < bottom):
                return {CollisionSide.RIGHT, penetration};
            case(top    < ball_radius):
                return {CollisionSide.TOP, penetration};
            case(bottom < ball_radius):
                return {CollisionSide.BOTTOM, penetration};
            default:
                return CollisionFault.NOT_COLLIDED?;
        }        
    };
    return CollisionFault.NOT_COLLIDED?;
}