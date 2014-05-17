(module micro-benchmark
  (benchmark-measure benchmark-run %gettime/microsecs current-benchmark-iterations generate-statistics)

  (import chicken scheme foreign)
  (use (only srfi-1 fold list-tabulate))

  (cond-expand
   ((or netbsd openbsd freebsd linux)
    (include "common.scm"))
   (macosx
    (include "macos.scm"))
   ((or mingw32 cygwin)
    (include "windows.scm"))
   (else (error "unsupported platform")))

  (define-syntax benchmark-measure
    (syntax-rules ()
      ((_  ?code)
       (let ((start  (%gettime/microsecs))
             (result ?code)
             (stop   (%gettime/microsecs)))
         (if (or (< start 0.0) (< stop 0.0))
             (error "Could not retrieve time reliably"))
         (- stop start)))))

  (define current-benchmark-iterations (make-parameter 100 (lambda (x)
                                                             (if (< x 2)
                                                                 (error "You need at least 2 benchmark iterations")
                                                                 x))))

  ;; run the given procedure n times and return statistics about the runtime
  ;; returns an alist with statistics
  (define-syntax benchmark-run
    (syntax-rules ()
      ((_ ?code)
       (benchmark-run (current-benchmark-iterations) ?code))
      ((_ ?iterations ?code)
       (let ((runtimes (list-tabulate ?iterations (lambda _ (benchmark-measure ?code)))))
         (generate-statistics runtimes)))))


  ;; should we also add percentiles to give a pointer on what to improve?
  ;; like the 95%?
  (define (generate-statistics runtimes)
    (let ((m (mean runtimes)))
      `((max  . ,(apply max runtimes))
        (min  . ,(apply min runtimes))
        (mean . ,m)
        (standard-deviation . ,(sample-standard-deviation runtimes m)))))

  (define (mean values)
    (/ (apply + values) (length values)))

  (define (sample-variance values #!optional (m (mean values)))
    (let ((amount (length values)))
      (unless (> amount 1)
        (error "Can not compute sample variance of less than 2 values"))

      (/ (fold (lambda (elt acc)
                 (+ acc (expt (- elt m) 2)))
               0
               values)
         (- amount 1))))

  (define (sample-standard-deviation values #!optional (m (mean values)))
    (sqrt (sample-variance values m)))

  )
