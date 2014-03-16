(foreign-declare "#include<time.h>")

(define %gettime/microsecs (foreign-lambda* double ()
                                                    "struct timespec ts;
                                                     if(clock_gettime(CLOCK_MONOTONIC,&ts) < 0){
                                                       C_return(-1.0);
                                                     }
                                                     C_return((double)ts.tv_sec * 1000000.0 + (double)ts.tv_nsec / 1000.0);"))
