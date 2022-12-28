(use-modules (gnu)
             (gnu system nss)
             (nongnu packages linux)
             (nongnu system linux-initrd))

(use-service-modules desktop networking ssh xorg)
(use-package-modules certs linux screen ssh)

(define bombaclaat
  (operating-system
    (kernel linux)
    (initrd microcode-initrd)
    (firmware (list sof-firmware linux-firmware))
    (host-name "bombaclaat")
    (timezone "Europe/Berlin")
    (locale "en_US.utf8")
    (keyboard-layout (keyboard-layout "us"))

    (bootloader (bootloader-configuration
                 (bootloader grub-efi-bootloader)
                 (targets (list "/boot/efi"))
                 (keyboard-layout keyboard-layout)))

    (mapped-devices (list (mapped-device
                           (source (uuid "47e53c2d-0c1b-4d40-b738-8ecba562986d"))
                           (target "cryptroot")
                           (type luks-device-mapping))
                          (mapped-device
                           (source "bombaclaat")
                           (targets (list "bombaclaat-home"
                                          "bombaclaat-root"
                                          "bombaclaat-swap"))
                           (type lvm-device-mapping))))

    (file-systems (cons* (file-system
                           (mount-point "/")
                           (device (file-system-label "root"))
                           (type "ext4")
                           (needed-for-boot? #t)
                           (dependencies mapped-devices))
                         (file-system
                           (mount-point "/boot/efi")
                           (device (uuid "9B92-14F6" 'fat32))
                           (type "vfat"))
                         (file-system
                           (mount-point "/home")
                           (device (file-system-label "home"))
                           (type "ext4")
                           (needed-for-boot? #t)
                           (dependencies mapped-devices))
                         %base-file-systems))

    (swap-devices (list (file-system-label "swap")))

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

    (packages (append (list (specification->package "nss-certs"))
                      %base-packages))

    (services (modify-services (cons (service gnome-desktop-service-type)
                                     %desktop-services)
                (guix-service-type config =>
                                   (guix-configuration
                                    (inherit config)
                                    (substitute-urls
                                     (append (list "https://substitutes.nonguix.org")
                                             %default-substitute-urls))
                                    (authorized-keys
                                     (append (list (local-file "./keys/nonguix.pub"))
                                             %default-authorized-guix-keys))))))))

bombaclaat
