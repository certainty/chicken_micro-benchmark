(use test micro-benchmark posix)

(test-begin "micro-benchmark")

(define epsilon (cond-expand ((or mingw32 cygwin) 0.0001) (else 0.0001)))
(define sleep-time (cond-expand ((or mingw32 cygwin) 2) (else 1)))

(parameterize ((current-test-epsilon epsilon))
  (test "benchmark-measure"
        1000000.0
        (benchmark-measure (sleep sleep-time)))
  (test-group "benchmark-run"
              (let ((result (parameterize ((current-benchmark-iterations 3)) (benchmark-run (sleep sleep-time)))))
                (test "min"
                      1000000.0
                      (alist-ref 'min result))
                (test "max"
                      1000000.0
                      (alist-ref 'max result))
                (test "runtimes"
                      3
                      (length (alist-ref 'runtimes result))))))

(test-end "micro-benchmark")
(test-exit)
