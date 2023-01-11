(define-module (r0man guix system desktop)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages suckless)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu services avahi)
  #:use-module (gnu services base)
  #:use-module (gnu services cups)
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
  #:export (desktop-operating-system))

(define %packages
  (list cl-stumpwm
        sbcl
        sbcl-local-time
        sbcl-slime-swank
        sbcl-slynk
        ;; sbcl-stumpwm-battery-portable
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
  (list (service cups-service-type
                 (cups-configuration
                  (web-interface? #t)
                  (extensions
                   (list cups-filters))))

        (service gnome-desktop-service-type)
        (service gdm-service-type)

        ;; (if (string-prefix? "x86_64" (or (%current-target-system)
        ;;                                  (%current-system)))
        ;;     (service gdm-service-type)
        ;;     (service sddm-service-type))

        ;; Screen lockers are a pretty useful thing and these are small.
        (screen-locker-service slock)
        (screen-locker-service xlockmore "xlock")

        ;; Add udev rules for MTP devices so that non-root users can access
        ;; them.
        (simple-service 'mtp udev-service-type (list libmtp))

        ;; Add polkit rules, so that non-root users in the wheel group can
        ;; perform administrative tasks (similar to "sudo").
        polkit-wheel-service

        ;; This is a volatile read-write file system mounted at /var/lib/gdm,
        ;; to avoid GDM stale cache and permission issues.
        gdm-file-system-service

        ;; The global fontconfig cache directory can sometimes contain
        ;; stale entries, possibly referencing fonts that have been GC'd,
        ;; so mount it read-only.
        fontconfig-file-system-service

        ;; NetworkManager and its applet.
        (service network-manager-service-type)
        (service wpa-supplicant-service-type)    ;needed by NetworkManager
        (simple-service 'network-manager-applet
                        profile-service-type
                        (list network-manager-applet))
        (service modem-manager-service-type)
        (service usb-modeswitch-service-type)

        ;; The D-Bus clique.
        (service avahi-service-type)
        (udisks-service)
        (service upower-service-type)
        (accountsservice-service)
        (service cups-pk-helper-service-type)
        (service colord-service-type)
        (geoclue-service)
        (service polkit-service-type)
        (elogind-service)
        (dbus-service)

        (service ntp-service-type)

        x11-socket-directory-service

        (service pulseaudio-service-type)
        (service alsa-service-type)))

(define desktop-operating-system
  (operating-system
    (inherit base-operating-system)
    (packages (append %packages (operating-system-packages base-operating-system)))
    (services (append %services (operating-system-services base-operating-system)))))

desktop-operating-system
