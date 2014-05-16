(module micro-benchmark
  (benchmark-measure benchmark-run %gettime/microsecs current-benchmark-iterations benchmark-compare compare generate-statistics)

  (import chicken scheme foreign)
  (use (only srfi-1 list-tabulate) (only data-structures alist-ref))

  (cond-expand
   ((or netbsd openbsd freebsd linux)
    (include "common.scm"))
   (macosx
    (include "macos.scm"))
   ((or mingw32 cygwin)
    (include "windows.scm"))
   (else (error "unsupported platform")))

  ;; returns a pair holding the runtime and the result of the invokation of code
  (define-syntax benchmark-measure
    (syntax-rules ()
      ((_  ?code)
       (let ((start  (%gettime/microsecs))
             (result ?code)
             (stop   (%gettime/microsecs)))
         (if (or (< start 0.0) (< stop 0.0))
             (error "Could not retrieve time reliably"))
         (- stop start)))))

  (define current-benchmark-iterations (make-parameter 100))

  ;; run the given procedure n times and return statistics about the runtime
  ;; returns an alist with statistics
  (define-syntax benchmark-run
    (syntax-rules ()
      ((_ ?code)
       (benchmark-run (current-benchmark-iterations) ?code))
      ((_ ?iterations ?code)
       (let ((runtimes (map (lambda _ (benchmark-measure ?code)) (iota ?iterations))))
         (generate-statistics runtimes)))))

  (define (generate-statistics runtimes)
    `((max . ,(apply max runtimes))
      (min . ,(apply min runtimes))
      (avg . ,(/ (apply + runtimes) (length runtimes)))
      (runtimes . ,runtimes)))

  (define (compare x y)
    (cond
     ((= x y) 0)
     ((< x y) -1)
     ((> x y) 1)))

  (define-syntax benchmark-compare
    (syntax-rules ()
      ((_ ?code-a ?code-b)
       (benchmark-compare (current-benchmark-iterations) ?code-a ?code-b))
      ((_ ?iterations ?code-a ?code-b)
       (let* ((result-a (benchmark-run ?code-a))
              (result-b (benchmark-run ?code-b))
              (avg-a (alist-ref result-a 'avg))
              (avg-b (alist-ref resutl-b 'avg)))
         (values (compare avg-a avg-b) result-a result-b)))))

)
