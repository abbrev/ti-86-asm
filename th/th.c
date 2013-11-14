
#define __USE_MISC
#include <setjmp.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "th.h"

/* wait for tick */
#define HALT()

struct thread threads[NUMTHREADS];
struct thread *current;

void th_init()
{
	struct thread *tp;
	
	for EACHTHREAD(tp) {
		tp->state = TH_FREE;
	}
	
	current = &threads[0];
	current->state = TH_RUNNING;
	
	setjmp(current->jmp_buf);
}

struct thread *th_create(int (*code)(void), char *stack)
{
	struct thread *tp;
	
	fprintf(stderr, "starting code %p on stack %p\n", code, stack);
	
	for EACHTHREAD(tp)
		if (tp->state == TH_FREE)
			break;
	
	if (tp == &threads[NUMTHREADS])
		return NULL;
	
	tp->state = TH_STARTING;
	
	tp->code = code;
	/*tp->stack = stack;*/
	
	/*
	tp->jmp_buf->sp = stack;
	tp->jmp_buf->pc = execthread;
	 */
	
	return tp;
}

void th_cancel(struct thread *tp)
{
	fprintf(stderr, "canceling thread %p\n", tp);
	
	tp->state = TH_FREE;
	th_wake(tp);
	th_yield();
}

void th_exit(int status)
{
	fprintf(stderr, "exiting current thread with status %d\n", status);
	
	current->state = TH_ZOMBIE;
	current->exitstatus = status;
	th_wake(current);
	th_yield();
	/* NORETURN */
}

int th_join(struct thread *tp)
{
	fprintf(stderr, "joining thread %p\n", tp);
	
	if (tp == current)
		return -1;
	
	while (tp->state != TH_FREE && tp->state != TH_ZOMBIE)
		th_sleep(tp);
	
	if (tp->state == TH_FREE)
		return -1;
	
	tp->state = TH_FREE;
	
	return tp->exitstatus;
}

void th_sleep(void *event)
{
	fprintf(stderr, "sleeping on %p\n", event);
	
	current->state = TH_WAITING;
	current->waitfor = event;
	
	th_yield();
}

void th_wake(void *event)
{
	struct thread *tp;
	
	fprintf(stderr, "waking threads that are sleeping on %p\n", event);
	
	for EACHTHREAD(tp)
		if (tp->state == TH_WAITING && tp->waitfor == event)
			tp->state = TH_RUNNING;
}

void th_yield()
{
	struct thread *tp;
	
	fprintf(stderr, "yielding\n");
	
	if (setjmp(current->jmp_buf))
		return;
	
	tp = current;
	for (;;) {
		if (++tp == &threads[NUMTHREADS])
			tp = &threads[0];
		
		switch (tp->state) {
		case TH_RUNNING:
			fprintf(stderr, "found running thread %d\n",
			 tp - &threads[0]);
			current = tp;
			longjmp(tp->jmp_buf, 1);
		case TH_STARTING:
			fprintf(stderr, "found starting thread %d\n",
			 tp - &threads[0]);
#if 0
			/* XXX: this is the only machine-dependent code in th */
			
			/* get a valid jmp_buf */
			setjmp(tp->jmp_buf);
			
			tp->jmp_buf->__jmpbuf[JB_SP] = (int)tp->stack;
			tp->jmp_buf->__jmpbuf[JB_PC] = (int)tp->code;
			/* XXX */
#endif
			current = tp;
			longjmp(tp->jmp_buf, 1);
		}
		
		if (tp == current && tp->state == TH_SLEEPING)
			HALT();
	}
}
