/*
 * cpp thread class
 */
#include "mutex.pml"

chan join = [0] of {byte};
bit m_op_mtx = UNLOCKED;
bit m_stop_mtx = UNLOCKED;
bool m_stop_requested = false;
byte m_tid = 0;

proctype thread() {
  bool stop_requested = false;
  do
    :: mutex_lock(m_stop_mtx);
       stop_requested = m_stop_requested;
       mutex_unlock(m_stop_mtx);
       if
	 :: stop_requested -> break;
	 :: else ->  skip;
       fi;
  od;
  join!_pid;
}

inline start() {
    mutex_lock(m_op_mtx);
    if
        :: m_tid == 0 ->
	   mutex_lock(m_stop_mtx);
	   m_stop_requested = false;
	   mutex_unlock(m_stop_mtx);
pthread_create:
	   m_tid = run thread();
pthread_create_ret:
           skip; 
	:: else ->
	   skip;	/* already started */
    fi;
    mutex_unlock(m_op_mtx);
}

inline stop() {
    mutex_lock(m_op_mtx);
user_stop:
    if
        :: m_tid != 0 ->
           mutex_lock(m_stop_mtx);
chosen:    m_stop_requested = true;
           mutex_unlock(m_stop_mtx);
pthread_join:
           join?m_tid;
pthread_join_ret:
           skip;
           m_tid = 0;
        :: else ->
           skip;	/* already stopped */
    fi;
    mutex_unlock(m_op_mtx);
}

proctype user() {
  do
    :: start()
    :: stop()
  od
}

init {
  atomic {
    run user();
    run user();
  }
}

/*
 *  1. thread safe
 *  1.1 two thread won't enter critical section
 *      critical section: pthread_create, pthread_join
 *
 *      scope: global
 *      pattern: absence
 */
#if 0
#define p (user[1]@pthread_create && user[2]@pthread_create)
#include "absence_global.nvr"
#endif

#if 0
#define p (user[1]@pthread_join && user[2]@pthread_join)
#include "absence_global.nvr"
#endif

/*
 *  2. no resource leak
 *  2.1 pthread_join is called whenever an user stops a thread
 *
 *      scope: global
 *      pattern: response
 */
#if 0
#define p (user[1]@user_stop && m_tid != 0)
#define q (user[1]@pthread_join)
#include "response_global.nvr"
#endif

#if 0
#define p (user[2]@user_stop && m_tid != 0)
#define q (user[2]@pthread_join)
#include "response_global.nvr"
#endif

#if 1
#define e (m_stop_mtx == UNLOCKED)
#define c (user[1]@chosen)
#define p (user[1]@user_stop && m_tid != 0)
#define q (user[1]@pthread_join)
#include "response_global_sf.nvr"
#endif

/*
 *  2. no resource leak
 *  2.2 tid which pthread_create() returned will be held until
 *      pthread_join() is called.
 *      <=>
 *      pthread_create() will not be called after pthread_create()
 *      is called until pthread_join() is called.
 *
 *      pattern: absence
 *      scope: after-until
 */

/*
 * since spin doesn't have 'X'(next) operator and we don't want to
 * include state when property spec start, we created label
 * pthread_create_ret
 */
#if 0
#define p (user[1]@pthread_create || user[2]@pthread_create)
#define q (user[1]@pthread_create_ret || user[2]@pthread_create_ret)
#define r (user[1]@pthread_join_ret || user[2]@pthread_join_ret)
#include "absence_afteruntil.nvr"
#endif

#if 0
#define p (user[1]@pthread_create || user[2]@pthread_create)
#define q (user[1]@pthread_create || user[2]@pthread_create)
#define r (user[1]@pthread_join_ret || user[2]@pthread_join_ret)
#include "absence_afteruntil_lo.nvr"
#endif
