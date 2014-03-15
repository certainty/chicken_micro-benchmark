;; get time in microsecond resolution
(foreign-declare "#include<mach/mach_time.h>")
(define %gettime/microsecs (foreign-lambda* double ()
                                            " static double factor = 0;
                                              if( factor == 0){
                                                mach_timebase_info_data_t info;
                                                mach_timebase_info(&info);
                                                /* factor to get nanosecs */
                                                factor = (double)info.numer / (double)info.denom;
                                              }
                                              uint64_t time = mach_absolute_time();

                                              C_return((double)time * factor / 1000.0);
                                            "))
