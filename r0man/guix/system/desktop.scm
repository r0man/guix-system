(define-module (r0man guix system desktop)
  #:use-module (gnu packages cups)
  #:use-module (gnu services cups)
  #:use-module (gnu services desktop)
  #:use-module (gnu system)
  #:use-module (gnu)
  #:use-module (r0man guix system base)
  #:export (desktop-operating-system))

(define %services
  (list (service cups-service-type
                 (cups-configuration
                  (web-interface? #t)
                  (extensions
                   (list cups-filters))))))

(define desktop-operating-system
  (operating-system
    (inherit base-operating-system)
    (packages (append (map specification->package
                           (list "sbcl"
                                 "sbcl-local-time"
                                 "sbcl-slime-swank"
                                 "sbcl-slynk"
                                 "sbcl-stumpwm-battery-portable"
                                 "sbcl-stumpwm-cpu"
                                 "sbcl-stumpwm-disk"
                                 "sbcl-stumpwm-globalwindows"
                                 "sbcl-stumpwm-kbd-layouts"
                                 "sbcl-stumpwm-mem"
                                 "sbcl-stumpwm-net"
                                 "sbcl-stumpwm-numpad-layouts"
                                 "sbcl-stumpwm-pamixer"
                                 "sbcl-stumpwm-pass"
                                 "sbcl-stumpwm-screenshot"
                                 "sbcl-stumpwm-stumptray"
                                 "sbcl-stumpwm-swm-gaps"
                                 "sbcl-stumpwm-ttf-fonts"
                                 "sbcl-stumpwm-wifi"
                                 "sbcl-stumpwm-winner-mode"
                                 "stumpish"
                                 "stumpwm"))
                      (operating-system-packages base-operating-system)))
    (services (append %desktop-services %services))))

desktop-operating-system
