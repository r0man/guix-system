(define-module (r0man guix system services)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu services auditd)
  #:use-module (gnu services avahi)
  #:use-module (gnu services base)
  #:use-module (gnu services cups)
  #:use-module (gnu services desktop)
  #:use-module (gnu services docker)
  #:use-module (gnu services networking)
  #:use-module (gnu services nix)
  #:use-module (gnu services security-token)
  #:use-module (gnu services ssh)
  #:use-module (gnu services virtualization)
  #:use-module (gnu services xorg)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (r0man guix system base)
  #:use-module (r0man guix system keyboard)
  #:use-module (r0man guix system udev)
  #:use-module (r0man guix system xorg)
  #:export (%auditd-service-type
            %bluetooth-service
            %cups-service
            %docker-service
            %libvirt-service
            %nix-service
            %openssh-service
            %pcscd-service-type
            %screen-locker-service
            %slim-service
            %udev-yubikey-service
            console-font-service-config
            guix-service-type-config))

(define %auditd-service-type
  (service auditd-service-type))

(define %bluetooth-service
  (service bluetooth-service-type))

(define %cups-service
  (service cups-service-type
           (cups-configuration
            (web-interface? #t)
            (extensions
             (list cups-filters)))))

(define %docker-service
  (service docker-service-type))

(define %libvirt-service
  (service libvirt-service-type
           (libvirt-configuration
            (unix-sock-group "libvirt")
            (tls-port "16555"))))

(define %nix-service
  (service nix-service-type))

(define %openssh-service
  (service openssh-service-type
           (openssh-configuration
            (openssh openssh-sans-x)
            (permit-root-login 'prohibit-password)
            (port-number 22))))

(define %pcscd-service-type
  (service pcscd-service-type))

(define %slim-service
  (service slim-service-type
           (slim-configuration
            (xorg-configuration
             (xorg-configuration
              (keyboard-layout %keyboard-layout)
              (extra-config (list %xorg-libinput-config)))))))

(define %screen-locker-service
  (screen-locker-service xlockmore "xlock"))

(define %udev-yubikey-service
  (udev-rules-service 'yubikey %udev-yubikey-rule))

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
    (append (list (local-file "./keys/nonguix.pub")
                  (local-file "./keys/precision.pub"))
            %default-authorized-guix-keys))))
