(define-module (r0man guix system bombaclaat)
  #:use-module (asahi guix initrd)
  #:use-module (asahi guix packages)
  #:use-module (asahi guix transformations)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services avahi)
  #:use-module (gnu services linux)
  #:use-module (gnu services networking)
  #:use-module (gnu services sound)
  #:use-module (gnu services ssh)
  #:use-module (gnu services xorg)
  #:use-module (gnu services)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu system nss)
  #:use-module (gnu system uuid)
  #:use-module (gnu system)
  #:use-module (r0man guix system desktop)
  #:use-module (r0man guix system keyboard)
  #:use-module (r0man guix system xorg))

(define %firmware
  (cons* asahi-firmware
         (operating-system-firmware desktop-operating-system)))

(define %packages
  (cons* alsa-ucm-conf-asahi
         asahi-firmware
         (replace-libdrm asahi-mesa-utils)
         asahi-scripts
         mesa-asahi-edge
         (operating-system-packages desktop-operating-system)))

(define %mapped-devices
  (list (mapped-device
         (source (uuid "56b68fba-21cb-49b5-ac44-84dc382f3426"))
         (target "cryptroot")
         (type luks-device-mapping))
        (mapped-device
         (source "bombaclaat")
         (targets (list "bombaclaat-root"
                        "bombaclaat-swap"))
         (type lvm-device-mapping))))

(define %file-systems
  (cons* (file-system
           (mount-point "/")
           (device "/dev/mapper/bombaclaat-root")
           (type "ext4")
           (needed-for-boot? #t)
           (dependencies %mapped-devices))
         (file-system
           (mount-point "/boot/efi")
           (device (uuid "9FBE-130E" 'fat32))
           (type "vfat"))
         %base-file-systems))

(define %services
  (modify-services (cons* (service kernel-module-loader-service-type
                                   '("asahi"
                                     "appledrm"))
                          (operating-system-user-services desktop-operating-system))
    (slim-service-type config =>
                       (slim-configuration
                        (inherit config)
                        (xorg-configuration
                         (xorg-configuration
                          ;; (drivers (list "modesetting" "vesa"))
                          (keyboard-layout %keyboard-layout)
                          (modules (list mesa-asahi-edge
                                         xf86-video-vesa
                                         xf86-video-fbdev
                                         xf86-input-libinput
                                         xf86-input-evdev
                                         xf86-input-keyboard
                                         xf86-input-mouse))
                          (extra-config (list %xorg-libinput-config
                                              %xorg-modeset-config))
                          (server (replace-mesa (replace-libdrm xorg-server)))))))))

(define %swap-devices
  (list (swap-space
         (target "/dev/mapper/bombaclaat-swap")
         (dependencies %mapped-devices))))

(define bombaclaat
  (operating-system
    (inherit desktop-operating-system)
    (host-name "bombaclaat")
    (kernel (replace-jemalloc asahi-linux-edge))
    (firmware %firmware)
    (initrd-modules asahi-initrd-modules-edge)
    (mapped-devices %mapped-devices)
    (file-systems %file-systems)
    (packages %packages)
    (services %services)
    (swap-devices %swap-devices)))

bombaclaat
