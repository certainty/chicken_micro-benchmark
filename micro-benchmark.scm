(module micro-benchmark
  (benchmark-measure benchmark-run %gettime/microsecs current-benchmark-iterations benchmark-compare compare)

  (import chicken scheme foreign)
  (use (only srfi-1 list-tabulate))

  (cond-expand
   ((or netbsd openbsd freebsd linux)
    (include "common.scm"))
   (macosx
    (include "macos.scm"))
   (win32
    (include "windows.scm"))
   (else (error "unsupported platform")))

  ;; return the runtime of the given procedure in microseconds
  (define-syntax benchmark-measure
    (syntax-rules ()
      ((_  ?code)
       (let ((start  0)
             (stop   0))
         (set! start (%gettime/microsecs))
         ?code
         (set! stop (%gettime/microsecs))
         (if (or (< start 0) (< stop 0))
             (error "Could not retrieve time reliably"))
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
      ((_ ?code)
       (benchmark-run (current-benchmark-iterations) ?code))
      ((_ ?iterations ?code)
       (let ((runtimes (list-tabulate ?iterations (lambda _ (benchmark-measure ?code)))))
         `((max . ,(apply max runtimes))
           (min . ,(apply min runtimes))
           (avg . ,(/ (fold + 0 runtimes) (length runtimes)))
           (runtimes . ,runtimes))))))

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
