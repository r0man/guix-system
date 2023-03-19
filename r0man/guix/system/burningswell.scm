(define-module (r0man guix system burningswell)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu bootloader)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services avahi)
  #:use-module (gnu services base)
  #:use-module (gnu services cuirass)
  #:use-module (gnu services networking)
  #:use-module (gnu services sound)
  #:use-module (gnu services ssh)
  #:use-module (gnu services xorg)
  #:use-module (gnu services)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu system nss)
  #:use-module (gnu system uuid)
  #:use-module (gnu system)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (r0man guix system base)
  #:use-module (r0man guix system keyboard)
  #:use-module (r0man guix system services)
  #:use-module (r0man guix system xorg))

(define %bootloader
  (bootloader-configuration
   (bootloader grub-bootloader)
   (keyboard-layout %keyboard-layout)
   (targets (list "/dev/sda" "/dev/sdb"))
   (terminal-outputs '(console))))

(define %cuirass-service
  (service cuirass-service-type
           (cuirass-configuration
            (specifications
             #~(list (specification
                      (name "asahi-guix")
                      (build '(channels asahi-guix))
                      (channels
                       (cons (channel
                              (name 'asahi-guix)
                              (branch "main")
                              (url "https://github.com/r0man/asahi-guix.git"))
                             %default-channels)))))
            (use-substitutes? #t)
            (remote-server (cuirass-remote-server-configuration)))))

(define %cuirass-remote-worker-service
  (service cuirass-remote-worker-service-type
           (cuirass-remote-worker-configuration
            (systems (list "aarch64-linux" "x86_64-linux"))
            (workers 2))))

(define %mapped-devices
  (list (mapped-device
         (source (list "/dev/sda2" "/dev/sdb2"))
         (target "/dev/md0")
         (type raid-device-mapping))))

(define %file-systems
  (cons (file-system
          (mount-point "/")
          (device (file-system-label "root"))
          (type "ext4")
          (dependencies %mapped-devices))
        %base-file-systems))

(define %packages
  (cons* (operating-system-packages base-operating-system)))

(define %services
  (cons* %avahi-service
         %cuirass-remote-worker-service
         %cuirass-service
         %docker-service
         %elogind-service
         %postgresql-service
         %qemu-service-x86-64
         %udev-fido2-service ;; TODO: Remove
         %unattended-upgrade-service
         (service static-networking-service-type
                  (list (static-networking
                         (addresses
                          (list (network-address
                                 (device "eth0")
                                 (value "136.243.174.102/26"))))
                         (routes
                          (list (network-route
                                 (destination "default")
                                 (gateway "136.243.174.65"))))
                         (name-servers '("1.1.1.1" "8.8.8.8")))))
         (operating-system-user-services base-operating-system)))

(define %swap-devices
  (list (swap-space (target "/swapfile"))))

(define burningswell
  (operating-system
    (inherit base-operating-system)
    (host-name "burningswell")
    (kernel linux-libre)
    ;; (firmware %firmware)
    (initrd-modules (cons "raid1" %base-initrd-modules))
    (bootloader %bootloader)
    (mapped-devices %mapped-devices)
    (file-systems %file-systems)
    (packages %packages)
    (services %services)
    (swap-devices %swap-devices)))

burningswell
