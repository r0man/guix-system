(define-module (r0man guix system bombaclaat)
  #:use-module (asahi guix initrd)
  #:use-module (asahi guix packages)
  #:use-module (asahi guix transformations)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages ssh)
  #:use-module (gnu services avahi)
  #:use-module (gnu services networking)
  #:use-module (gnu services ssh)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu system nss)
  #:use-module (gnu system uuid)
  #:use-module (gnu system)
  #:use-module (r0man guix system desktop))

(define %firmware
  (cons* asahi-firmware
         (operating-system-firmware desktop-operating-system)))

(define %packages
  (cons* alsa-ucm-conf-asahi
         asahi-firmware
         asahi-mesa-utils
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
    (swap-devices %swap-devices)))

bombaclaat
