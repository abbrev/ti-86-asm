#ifndef _TH_H_
#define _TH_H_ 1

#include <setjmp.h>

#define NUMTHREADS 2

struct thread {
	enum { TH_FREE, TH_STARTING, TH_RUNNING, TH_WAITING, TH_ZOMBIE, } state;
	int exitstatus;
	void *waitfor;
	void *code;
	char *stack;
	jmp_buf jmp_buf;
};

#define EACHTHREAD(tp) (tp = threads; tp < &threads[NUMTHREADS]; ++tp)

void th_init();
struct thread *th_create(int (*code)(void), char *stack);
void th_cancel(struct thread *tp);
void th_exit(int status);
int th_join(struct thread *tp);
void th_sleep(void *event);
void th_wake(void *event);
void th_yield();

#endif /* _TH_H_ */
