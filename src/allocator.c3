module allocator(<Type>);

import std::collections;
import std::io;

struct Pool{
    List(<Type>) entity_pool;
    List(<usz>) active_pool;
    List(<usz>) active_pool_map;
    List(<usz>) deleted_pool;
    usz next_max_id;

    usz deleted_len;
    usz active_len;
}

fn void Pool.init(&self, usz capacity = 16){
    io::printfn("Init pool with: %d", capacity);
    self.entity_pool.new_init(capacity);
    self.active_pool.new_init(capacity);
    self.deleted_pool.new_init(capacity);
    self.active_pool_map.new_init(capacity);
}



fn usz Pool.new(Pool *self, Type data){
    usz index = 0;
    if(self.deleted_len > 0){
        index = self.deleted_pool[self.deleted_len-1];
        self.deleted_len--;
    }else{
        self.entity_pool.reserve(1);   
        self.entity_pool.size++;
        index = self.next_max_id++;
        self.active_pool_map.reserve(1);
        self.active_pool_map.size++;
    }

    self.active_len++;
    if(self.active_len > self.active_pool.len()){
        self.active_pool.reserve(1);   
        self.active_pool.size++;
    }

    self.active_pool_map[index] = self.active_len-1;
    self.entity_pool[index] = data;
    self.active_pool[self.active_len-1] = index;
    
    return index;
}

fn void Pool.delete(Pool *self, usz index){
    if(self.deleted_len >= self.deleted_pool.len()){
        self.deleted_pool.reserve(1);   
        self.deleted_pool.size++;
    }

    usz id = self.active_pool[index];
    if(self.active_len > 1) {
        usz id_to_move = self.active_pool[self.active_len-1];
        self.active_pool[index] = id_to_move;
        self.active_pool_map[id_to_move] = index;  
    }
    self.active_len--;
    self.deleted_pool[self.deleted_len ] = id;
    self.deleted_len++;
}