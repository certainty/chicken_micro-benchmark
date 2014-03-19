(use test micro-benchmark posix)

(test-begin "micro-benchmark")

;; (sleep i) seems to actually sleep i-1 seconds on windows so if you see the tests failing it's probably because of this

(parameterize ((current-test-epsilon 0.001))
  (test "benchmark-measure returns runtime"
        1000000.0
        (car (benchmark-measure (begin (sleep 1) 'test))))
  (test "benchmark-measure returns result"
        'test
        (cdr (benchmark-measure (begin (sleep 1) 'test))))
  (test-group "benchmark-run"
              (let ((result (parameterize ((current-benchmark-iterations 3))
                              (benchmark-run (begin (sleep 1) 'test)))))
                (test "min"
                      1000000.0
                      (alist-ref 'min result))
                (test "max"
                      1000000.0
                      (alist-ref 'max result))
                (test "values"
                      '(test test test)
                      (alist-ref 'values result))
                (test "values in order of invokation"
                      '(1 2 3)
                      (let ((i 0))
                        (alist-ref 'values (benchmark-run 3 (begin (set! i (add1 i)) i)))))
                (test "runtimes"
                      3
                      (length (alist-ref 'runtimes result))))))

(test-end "micro-benchmark")
(test-exit)
