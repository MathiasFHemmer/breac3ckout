module systems::sound;

import raylib5;
import std::collections;
import std::io;

struct SoundPool{
    List(<Sound>)   sound_pool;
    int             last_id_played;
}

struct SoundManager{
    Map(<String, Sound>) generic_sound_pool;
    Map(<String, SoundPool>) context_sound_pool;
}

fn void SoundManager.load_sound(SoundManager* self, String name, String filename){
    self.generic_sound_pool.set(name, rl::loadSound((ZString)filename));
}

fn void SoundManager.load_sound_pool(SoundManager* self, String pool_name, String file_name, int amount){
    io::printfn("Pool name: %s, file name: %s, amount: %d", pool_name, file_name, amount);
    Sound sound = rl::loadSound((ZString)file_name);
    if(self.context_sound_pool.has_key(pool_name)){
        SoundPool* context = self.context_sound_pool.get_ref(pool_name)!!;
        context.sound_pool.push(sound);
        for(int i = 1; i <= amount; i++){
            context.sound_pool.push(rl::loadSoundAlias(sound));
        }
    }else{
        SoundPool context;
        context.sound_pool.push(sound);
        for(int i = 1; i <= amount; i++){
            context.sound_pool.push(rl::loadSoundAlias(sound)); 
        }
        self.context_sound_pool.set(pool_name, context);
    }
}

fn void SoundManager.play_sound(&self, String name){
    rl::playSound(self.generic_sound_pool.get(name)!!);
}

fn void SoundManager.play_sound_from_pool(&self, String pool_name){
    if (try context = self.context_sound_pool.get_ref(pool_name)){
        int index = (int)context.sound_pool.len();
        rl::playSound(context.sound_pool[context.last_id_played]);
        context.last_id_played++;
        context.last_id_played = context.last_id_played % index;
    }
}

fn int SoundManager.get_last_played_index(&self, String pool_name){
    if (try context = self.context_sound_pool.get(pool_name)){
        return context.last_id_played;
    }
    return 0;
}