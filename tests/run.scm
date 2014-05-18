(use test micro-benchmark posix)

(test-begin "micro-benchmark")

;; (sleep i) seems to actually sleep i-1 seconds on windows so if you see the tests failing it's probably because of this

(parameterize ((current-test-epsilon 0.001))
  (test "benchmark-measure returns runtime"
        1000000.0
        (benchmark-measure (begin (sleep 1) 'test)))
  (test-group "benchmark-run"
              (let ((result (parameterize ((current-benchmark-iterations 3))
                              (benchmark-run (begin (sleep 1) 'test)))))
                (test "min"
                      1000000.0
                      (alist-ref 'min result))
                (test "max"
                      1000000.0
                      (alist-ref 'max result))
                (test "mean"
                      1000000.0
                      (alist-ref 'mean result))
                (test "deviation for a single result"
                      0.0
                      (alist-ref 'standard-deviation (benchmark-run 1 #f)))

                )))

(test-end "micro-benchmark")
(test-exit)
