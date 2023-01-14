(define-module (r0man guix system keyboard)
  #:use-module (gnu system keyboard)
  #:export (%keyboard-layout %keyboard-options))

(define %keyboard-options
  '("altwin:swap_lalt_lwin"
    "caps:ctrl_modifier"
    "terminate:ctrl_alt_bksp"))

(define %keyboard-layout
  (keyboard-layout "us" #:options %keyboard-options))
