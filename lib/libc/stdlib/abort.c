//------------------------------------------------------------------------------
// includes
//------------------------------------------------------------------------------
// libc includes
#include <stdlib.h>
#include <stdio.h>

//------------------------------------------------------------------------------
// abort
//------------------------------------------------------------------------------
__attribute__((__noreturn__))
void abort(void)
{
    printf("Aborted...");
    while ( 1 ) { }
}
