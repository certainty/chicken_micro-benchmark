;; get time in microsecond resolution
(define %gettime/microsecs (foreign-lambda* double ()
                                                    "struct timespec ts;
                                                     clock_gettime(CLOCK_MONOTONIC,&ts);
                                                     C_return((double)ts.tv_sec * 1000000.0 + (double)ts.tv_nsec / 1000.0);"))
