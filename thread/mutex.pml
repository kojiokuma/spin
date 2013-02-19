#define UNLOCKED 0
#define LOCKED 1

inline mutex_lock(mutex) {
  d_step{ mutex == UNLOCKED -> mutex = LOCKED}
}

inline mutex_unlock(mutex) {
  mutex = UNLOCKED;
}
