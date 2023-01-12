(define-module (r0man guix system services)
  #:use-module (gnu packages cups)
  #:use-module (gnu services cups)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages ssh)
  #:use-module (gnu services base)
  #:use-module (gnu services avahi)
  #:use-module (gnu services desktop)
  #:use-module (gnu services networking)
  #:use-module (gnu services ssh)
  #:use-module (gnu services virtualization)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (%cups-service
            %libvirt-service
            %openssh-service
            console-font-service-config
            guix-service-type-config))

(define %cups-service
  (service cups-service-type
           (cups-configuration
            (web-interface? #t)
            (extensions
             (list cups-filters)))))

(define %libvirt-service
  (service libvirt-service-type
           (libvirt-configuration
            (unix-sock-group "libvirt")
            (tls-port "16555"))))

(define %openssh-service
  (service openssh-service-type
           (openssh-configuration
            (openssh openssh-sans-x)
            (port-number 22))))

(define (console-font-service-config config)
  (map (lambda (tty)
         (cons tty (file-append font-terminus "/share/consolefonts/ter-132n")))
       '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6")))


(define (guix-service-type-config config)
  (guix-configuration
   (inherit config)
   (substitute-urls
    (append (list "https://substitutes.nonguix.org")
            %default-substitute-urls))
   (authorized-keys
    (append (list (local-file "./keys/nonguix.pub"))
            %default-authorized-guix-keys))))
