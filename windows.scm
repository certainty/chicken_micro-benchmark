(foreign-declare "#include<windows.h>")
(define %factor ((foreign-lambda* double ()
                                   "LARGE_INTEGER li;
                                    if(!QueryPerformanceFrequency(&li)){
                                       C_return(-1.0);
                                    }
                                    C_return((double)li.QuadPart/1000000.0);"
                                   )))
(when (< %factor 0.0) (error "Could not determine scale factor"))

(define (%gettime/microsecs)
  (let ((time ((foreign-lambda* double ()
                                 "LARGE_INTEGER li;
                                  if(!QueryPerformanceCounter(&li)){
                                    C_return(-1.0);
                                  }
                                  C_return((double)li.QuadPart);"))))
    (/ time %factor)))
