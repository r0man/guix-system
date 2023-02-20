(define-module (r0man guix system udev)
  #:use-module (gnu services base)
  #:export (%udev-yubikey-rule))

(define %udev-yubikey-rule
  (udev-rule
   "90-yubikey.rules"
   (string-append "KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\", ATTRS{idProduct}==\"0407\", GROUP=\"plugdev\", ATTRS{idVendor}==\"1050\" TAG+=\"uaccess\"" "\n")))
