;; get time in microsecond resolution
(define %gettime/microsecs (foreign-lambda* double ()
                                            " static double factor = 0.0;
                                              LARGE_INTEGER li;

                                              if(factor ==  0.0){
                                                 if(!QueryPerformanceFrequency(&li)){
                                                   C_return(-1.0);
                                                 }
                                                 /* microsecs */
                                                 factor = double(li.QuadPart)/1000000.0;
                                              }
                                              if(!QueryPerformanceCounter(&li)){
                                                C_return(-1.0);
                                              }
                                              C_return((double)li.QuadPart / factor);
                                            "))
