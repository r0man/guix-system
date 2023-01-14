(define-module (r0man guix system desktop)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages suckless)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu services avahi)
  #:use-module (gnu services base)
  #:use-module (gnu services dbus)
  #:use-module (gnu services desktop)
  #:use-module (gnu services networking)
  #:use-module (gnu services sddm)
  #:use-module (gnu services sound)
  #:use-module (gnu services xorg)
  #:use-module (gnu system)
  #:use-module (gnu)
  #:use-module (guix utils)
  #:use-module (r0man guix system base)
  #:use-module (srfi srfi-1)
  #:use-module (r0man guix system services)
  #:export (desktop-operating-system))

(define %packages
  (list cl-stumpwm
        sbcl
        sbcl-local-time
        sbcl-slime-swank
        sbcl-slynk
        sbcl-stumpwm-battery-portable
        sbcl-stumpwm-cpu
        sbcl-stumpwm-disk
        sbcl-stumpwm-globalwindows
        sbcl-stumpwm-kbd-layouts
        sbcl-stumpwm-mem
        sbcl-stumpwm-net
        sbcl-stumpwm-numpad-layouts
        sbcl-stumpwm-pamixer
        sbcl-stumpwm-pass
        sbcl-stumpwm-screenshot
        sbcl-stumpwm-stumptray
        sbcl-stumpwm-swm-gaps
        sbcl-stumpwm-ttf-fonts
        sbcl-stumpwm-wifi
        sbcl-stumpwm-winner-mode
        stumpish
        stumpwm))

(define %services
  (modify-services (cons* %cups-service
                          %libvirt-service
                          %openssh-service
                          (service gdm-service-type)
                          %desktop-services)
    (delete sddm-service-type)
    (console-font-service-type config => (console-font-service-config config))
    (guix-service-type config => (guix-service-type-config config))))

(define desktop-operating-system
  (operating-system
    (inherit base-operating-system)
    (packages (append %packages (operating-system-packages base-operating-system)))
    (services %services)))

desktop-operating-system
