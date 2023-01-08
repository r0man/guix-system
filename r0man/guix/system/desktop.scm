(define-module (r0man guix system desktop)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (r0man guix system base)
  #:export (desktop-operating-system))

(define desktop-operating-system
  (operating-system
    (inherit base-operating-system)
    (packages (append (map specification->package
                           (list "stumpwm"))
                      (operating-system-packages base-operating-system)))
    ;; (services (operating-system-services base-operating-system))
    ))

desktop-operating-system
