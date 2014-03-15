(module micro-benchmark
  (benchmark-measure benchmark-run %gettime/microsecs current-benchmark-iterations)

  (import chicken scheme foreign)
  (use (only srfi-1 list-tabulate))

  (cond-expand
   ((or netbsd openbsd freebsd linux)
    (include "common.scm"))
   (macosx
    (include "macos.scm"))
   ;;windows feature?
   (else))

  ;; return the runtime of the given procedure in microseconds
  (define-syntax benchmark-measure
    (syntax-rules ()
      ((_  code)
       (let ((start  0)
             (stop   0))
         (set! start (%gettime/microsecs))
         code
         (set! stop (%gettime/microsecs))
         (- stop start)))))

  (define current-benchmark-iterations (make-parameter 100))

  ;; run the given procedure n times and return statistics about the runtime
  ;; returns an alist with
  ;; * max - maximum runtime
  ;; * min - minimum runtime
  ;; * avg - average runtime
  ;; * runtimes - list of all runtimes
  (define-syntax benchmark-run
    (syntax-rules ()
      ((_ code)
       (benchmark-run (current-benchmark-iterations) code))
      ((_ iterations code)
       (let ((runtimes (list-tabulate iterations (lambda _ (benchmark-measure code)))))
         `((max . ,(apply max runtimes))
           (min . ,(apply min runtimes))
           (avg . ,(/ (fold + 0 runtimes) (length runtimes)))
           (runtimes . ,runtimes))))))

)
