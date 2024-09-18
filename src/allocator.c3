module allocator(<Type>);

import std::collections;
import std::io;

interface PoolHandler{
    fn void delete(usz index);
    fn usz! new(Type data);
    fn usz get_next_id();
    fn void init(usz capacity);
}

struct Pool{
    List(<Type>) entity_pool;
    List(<usz>) active_pool;
    PriorityQueue(<usz>) deleted_pool;
    usz next_max_id;
}

fn void Pool.init(&self, usz capacity = 16){
    io::printfn("Init pool with: %d", capacity);
    self.entity_pool.new_init(capacity);
    self.active_pool.new_init(capacity);
    self.deleted_pool.new_init(capacity);
}

fn usz Pool.get_next_id(Pool *self){
     if(self.deleted_pool.len() > 0) return self.deleted_pool.first()!!;
     return self.next_max_id;
}

fn usz Pool.new(Pool *self, Type data){
    //io::printf("Next index: %d, Main pool size: %d. Deleted pool size: %d. Active pool size: %d", self.next_max_id, self.entity_pool.len(), self.deleted_pool.len(), self.active_pool.len());

    usz index = 0;
    if(self.deleted_pool.len() > 0){
        index = self.deleted_pool.pop()!!;
        //io::printfn(" Reusing index: %d", index);
    }else{
        self.entity_pool.reserve(1);   
        self.entity_pool.size++;
        index = self.next_max_id++;
        //io::pri  ntfn("New index: %d, entity pool capacity: %d", index, self.entity_pool.capacity);
    }                          
    self.active_pool.push(index);
    self.entity_pool[index] = data;
    
    return index;
}

fn void Pool.delete(Pool *self, usz index) @dynamic{
    self.active_pool.remove_item(index);
    self.deleted_pool.push(index);
}