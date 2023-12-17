(define-module (r0man guix system hetzner)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu bootloader)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages)
  #:use-module (gnu services base)
  #:use-module (gnu services networking)
  #:use-module (gnu services ssh)
  #:use-module (gnu services)
  #:use-module (gnu system accounts)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu system)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:export (hetzner-operating-system))

(define %keyboard-layout
  (keyboard-layout "us" #:options '("caps:ctrl_modifier")))

(define %bootloader
  (bootloader-configuration
   (bootloader grub-efi-bootloader)
   (keyboard-layout %keyboard-layout)
   (targets (list "/boot/efi"))))

(define %file-systems
  (cons* (file-system
           (mount-point "/")
           (device "/dev/sda1")
           (type "ext4")
           (needed-for-boot? #t))
         (file-system
           (mount-point "/boot/efi")
           (device "/dev/sda15")
           (type "vfat"))
         %base-file-systems))

(define %initrd-modules
  (cons* "sd_mod" "virtio_scsi" %base-initrd-modules))

(define %kernel-arguments
  '("vga=0x317" "console=ttyAMA0" "console=tty0"))

(define %packages
  (append (map specification->package
               '("e2fsprogs"
                 "git"
                 "htop"
                 "net-tools"
                 "network-manager"
                 "nss-certs"))
          %base-packages))

(define %users
  (list (user-account
         (name "roman")
         (comment "Roman")
         (group "users")
         (home-directory "/home/roman")
         (supplementary-groups '("audio" "netdev" "video" "wheel")))))

(define %openssh-service
  (service openssh-service-type
           (openssh-configuration
            (authorized-keys
             `(("root" ,(local-file "keys/roman.pub"))
               ("roman" ,(local-file "keys/roman.pub"))))
            (openssh openssh-sans-x)
            (permit-root-login 'prohibit-password)
            (port-number 22))))

(define %services
  (cons* %openssh-service
         (service dhcp-client-service-type)
         %base-services))

(define hetzner-operating-system
  (operating-system
    (host-name "hetzner")
    (timezone "Etc/UTC")
    (locale "en_US.utf8")
    (kernel linux-libre)
    (kernel-arguments %kernel-arguments)
    (bootloader %bootloader)
    (initrd-modules %initrd-modules)
    (file-systems %file-systems)
    (packages %packages)
    (services %services)
    (users %users)))

hetzner-operating-system
