(define-module (r0man guix deploy bombaclaat)
  #:use-module (r0man guix system bombaclaat)
  #:use-module (gnu machine)
  #:use-module (gnu machine ssh))

(define machines
  (list (machine
         (operating-system bombaclaat-operating-system-edge)
         (environment managed-host-environment-type)
         (configuration (machine-ssh-configuration
                         (allow-downgrades? #t)
                         (host-name "localhost")
                         (identity "~/.ssh/id_rsa")
                         (system "aarch64-linux"))))))

machines
