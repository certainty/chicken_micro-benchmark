(use test micro-benchmark posix)

(test-begin "micro-benchmark")

(parameterize ((current-test-epsilon 0.0001))
  (test "benchmark-measure"
        1000000.0
        (benchmark-measure (sleep 1)))
  (test-group "benchmark-run"
              (let ((result (parameterize ((current-benchmark-iterations 3)) (benchmark-run (sleep 1)))))
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
