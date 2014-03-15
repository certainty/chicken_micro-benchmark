(module micro-benchmark
  (benchmark-measure benchmark-run)

  (import chicken scheme foreign)

  (cond-expand
   ((or netbsd openbsd freebsd linux)
    (include "common.scm"))
   (macosx
    (include "macos.scm"))
   ;;windows feature?
   (else))



)
