(define-module (r0man system bombaclaat)
  #:use-module (asahi initrd)
  #:use-module (asahi installer)
  #:use-module (asahi packages)
  #:use-module (gnu services networking)
  #:use-module (gnu services ssh)
  #:use-module (gnu system nss)
  #:use-module (gnu)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (srfi srfi-1))

(use-service-modules networking ssh xorg)
(use-package-modules certs linux screen ssh)

(define bombaclaat
  (operating-system
    (host-name "bombaclaat")
    (locale "en_US.utf8")
    (timezone "Europe/Berlin")
    (keyboard-layout (keyboard-layout "us"))
    (bootloader (bootloader-configuration
                 (bootloader grub-efi-removable-bootloader)
                 (targets (list "/boot/efi"))
                 (keyboard-layout keyboard-layout)))
    (kernel asahi-linux-edge)
    (kernel-arguments
     (append '("modprobe.blacklist=radeon"
               ;; Prevent network interfaces from having really long
               ;; names. This can cause an issue with wpa_supplicant
               ;; when you try to connect to a wifi network.
               "net.ifnames=0"
               ;; "quiet"
               )
             %default-kernel-arguments))
    (firmware (list linux-firmware asahi-firmware))
    (initrd asahi-initrd)
    ;; (initrd microcode-initrd)
    ;; (initrd (lambda (file-systems . rest)
    ;;           ;; Create a standard initrd but set up networking
    ;;           ;; with the parameters QEMU expects by default.
    ;;           (apply base-initrd file-systems
    ;;                  #:qemu-networking? #f
    ;;                  rest)))
    (initrd-modules
     '(;; Asahi
       ;; For NVMe & SMC
       ;; "apple-mailbox"
       ;; For NVMe
       "nvme-apple"
       ;; For USB and HID
       "pinctrl-apple-gpio"
       ;; SMC core
       ;; "macsmc" "macsmc-rtkit"
       ;; For USB
       "apple-dart"
       "dwc3"
       "dwc3-of-simple"
       ;; "gpio_macsmc"
       "i2c-apple"
       "nvmem-apple-efuses"
       "pcie-apple"
       "phy-apple-atc"
       "tps6598x"
       "xhci-pci"
       ;; For HID
       "spi-apple" "spi-hid-apple" "spi-hid-apple-of"
       ;; For RTC
       "rtc-macsmc" "simple-mfd-spmi"
       ;; "spmi-apple-controller"
       "nvmem_spmi_mfd"
       ;; For MTP HID
       "apple-dockchannel" "dockchannel-hid"
       ;; "apple-rtkit-helper"
       ;; Guix
       "usb-storage"
       "uas"
       "usbhid"
       "hid-apple"
       "dm-crypt"
       "serpent_generic"
       "wp512"
       "nls_iso8859-1"
       "virtio_pci"
       "virtio_balloon"
       "virtio_blk"
       "virtio_net"
       "virtio-rng"))
    (mapped-devices (list (mapped-device
                           (source (uuid "65d8f2a0-9ebc-44a4-8d68-adeae9221701"))
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
    (swap-devices (list (swap-space
                         (target (file-system-label "swap"))
                         (dependencies mapped-devices))))
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
                                 "lvm2-static"
                                 "nss-certs"))
                      %base-packages))
    (services (modify-services (append (list (service dhcp-client-service-type)
                                             (service openssh-service-type
                                                      (openssh-configuration
                                                       (openssh openssh-sans-x)
                                                       (port-number 22))))
                                       %base-services)
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
