(foreign-declare "#include<mach/mach_time.h>")

;; we immediatly determine the factor
;; it should not change as long as the machine runs
(define %factor ((foreign-lambda* double ()
                                  "mach_timebase_info_data_t info;
                                   mach_timebase_info(&info);
                                   C_return((double)info.numer / (double)info.denom);")))

(when (< %factor 0.0) (error "Could not determine scale factor"))

(define %gettime/microsecs
  (let ((time ((foreign-lambda* double ()
                                 " uint64_t time = mach_absolute_time();
                                   C_return((double)time / 1000.0);
                                 "))))
    (* time %factor)))
