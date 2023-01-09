(define-module (r0man guix system bombaclaat)
  #:use-module (asahi installer)
  #:use-module (asahi packages)
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
  (cons asahi-firmware (operating-system-firmware desktop-operating-system)))

(define %modules
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

(define %mapped-devices
  (list (mapped-device
         (source (uuid "f06f4977-d529-4890-9d0e-4ad697886dce"))
         (target "cryptroot")
         (type luks-device-mapping))
        (mapped-device
         (source "bombaclaat")
         (targets (list "bombaclaat-home"
                        "bombaclaat-root"
                        "bombaclaat-swap"))
         (type lvm-device-mapping))))

(define %file-systems
  (list (file-system
          (mount-point "/")
          (device "/dev/mapper/bombaclaat-root")
          ;; (device (file-system-label "root"))
          (type "ext4")
          (needed-for-boot? #t)
          (dependencies %mapped-devices))
        (file-system
          (mount-point "/boot/efi")
          (device (uuid "9B92-14F6" 'fat32))
          (type "vfat"))
        (file-system
          (mount-point "/home")
          (device "/dev/mapper/bombaclaat-home")
          ;; (device (file-system-label "home"))
          (type "ext4")
          (needed-for-boot? #t)
          (dependencies %mapped-devices))))

(define %swap-devices
  (list (swap-space
         (target (file-system-label "swap"))
         (dependencies %mapped-devices))))

(define bombaclaat
  (operating-system
    (inherit desktop-operating-system)
    (host-name "bombaclaat")
    (kernel asahi-linux-edge)
    (firmware %firmware)
    (initrd-modules %modules)
    (mapped-devices %mapped-devices)
    (file-systems (append %file-systems %base-file-systems))
    (swap-devices %swap-devices)))

bombaclaat
