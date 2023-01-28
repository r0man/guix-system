(define-module (r0man guix system base)
  #:use-module (gnu system nss)
  #:use-module (gnu)
  #:use-module (guix packages)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (r0man guix system keyboard)
  #:use-module (r0man guix system services)
  #:export (base-operating-system))

(define %packages
  (map specification->package
       '("cryptsetup-static"
         "e2fsprogs"
         "emacs-next"
         "lvm2-static"
         "network-manager"
         "nss-certs")))

(define %users
  (list (user-account
         (name "r0man")
         (comment "r0man")
         (group "users")
         (home-directory "/home/r0man")
         (supplementary-groups '("audio" "docker" "netdev" "video" "wheel")))
        (user-account
         (name "roman")
         (comment "Roman Scherer")
         (group "users")
         (home-directory "/home/roman")
         (supplementary-groups '("audio" "docker" "netdev" "video" "wheel")))))

(define %services
  (modify-services (cons* %libvirt-service
                          %openssh-service
                          %base-services)
    (console-font-service-type config => (console-font-service-config config))
    (guix-service-type config => (guix-service-type-config config))))

(define-public base-operating-system
  (operating-system
    (host-name "base")
    (locale "en_US.utf8")
    (timezone "Europe/Berlin")
    (keyboard-layout %keyboard-layout)
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
                     (mount-point "/")
                     (device "none")
                     (type "tmpfs")
                     (check? #f))
                   %base-file-systems))
    (users (append %users %base-user-accounts))
    (packages (append %packages %base-packages))
    (services %services)))

base-operating-system
