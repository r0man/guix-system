(define-module (r0man system base)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages ssh)
  #:use-module (gnu services avahi)
  #:use-module (gnu services cups)
  #:use-module (gnu services docker)
  #:use-module (gnu services networking)
  #:use-module (gnu services ssh)
  #:use-module (gnu services virtualization)
  #:use-module (gnu system nss)
  #:use-module (gnu)
  #:use-module (guix packages)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (srfi srfi-1)
  #:export (base-operating-system))

(define base-operating-system
  (operating-system
    (host-name "base")
    (locale "en_US.utf8")
    (timezone "Europe/Berlin")
    (keyboard-layout (keyboard-layout "us"))

    (bootloader (bootloader-configuration
                 (bootloader grub-efi-removable-bootloader)
                 (targets (list "/boot/efi"))
                 (keyboard-layout keyboard-layout)))

    (kernel linux)
    (kernel-arguments
     (append '("modprobe.blacklist=radeon"
               ;; Prevent network interfaces from having really long
               ;; names. This can cause an issue with wpa_supplicant
               ;; when you try to connect to a wifi network.
               "net.ifnames=0"
               ;; "quiet"
               )
             %default-kernel-arguments))
    (firmware (list linux-firmware))

    (initrd microcode-initrd)

    (file-systems (cons*
                   (file-system
                     (mount-point "/tmp")
                     (device "none")
                     (type "tmpfs")
                     (check? #f))
                   %base-file-systems))

    (users (cons* (user-account
                   (name "roman")
                   (comment "Roman Scherer")
                   (group "users")
                   (home-directory "/home/roman")
                   (supplementary-groups '("audio"
                                           "netdev"
                                           "video"
                                           "wheel")))
                  %base-user-accounts))

    (packages (append (map specification->package
                           (list "cryptsetup-static"
                                 "e2fsprogs"
                                 "emacs-next"
                                 "lvm2-static"
                                 "nss-certs"))
                      %base-packages))

    (services (modify-services (append (list (service avahi-service-type)
                                             (service cups-service-type
                                                      (cups-configuration
                                                       (web-interface? #t)
                                                       (extensions
                                                        (list cups-filters))))
                                             (service dhcp-client-service-type)
                                             (service libvirt-service-type
                                                      (libvirt-configuration
                                                       (unix-sock-group "libvirt")
                                                       (tls-port "16555")))

                                             (service openssh-service-type
                                                      (openssh-configuration
                                                       (openssh openssh-sans-x)
                                                       (port-number 22))))
                                       %base-services)
                (console-font-service-type config =>
                                           (map (lambda (tty)
                                                  (cons tty (file-append
                                                             font-terminus
                                                             "/share/consolefonts/ter-132n")))
                                                '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6")))
                (guix-service-type config =>
                                   (guix-configuration
                                    (inherit config)
                                    (substitute-urls
                                     (append (list "https://substitutes.nonguix.org")
                                             %default-substitute-urls))
                                    (authorized-keys
                                     (append (list (local-file "./keys/nonguix.pub"))
                                             %default-authorized-guix-keys))))))))
