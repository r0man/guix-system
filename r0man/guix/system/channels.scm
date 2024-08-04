(define-module (r0man guix system channels)
  #:use-module (guix channels))

(define-public asahi-channel
  (channel
   (name 'asahi)
   (branch "main")
   (url "https://github.com/asahi-guix/channel")
   (introduction
    (make-channel-introduction
     "3eeb493b037bea44f225c4314c5556aa25aff36c"
     (openpgp-fingerprint
      "D226 A339 D8DF 4481 5DDE  0CA0 3DDA 5252 7D2A C199")))))

(define guix-channel
  (channel
   (name 'guix)
   (url "https://github.com/asahi-guix/guix")
   (branch "main")
   (introduction
    (make-channel-introduction
     "59c86958338970cac132f45da37de3b00a26a8cc"
     (openpgp-fingerprint
      "D226 A339 D8DF 4481 5DDE  0CA0 3DDA 5252 7D2A C199")))))

(define-public system-channel
  (channel
   (name 'r0man-system)
   (url "https://github.com/r0man/guix-system")
   (branch "asahi")
   (introduction
    (make-channel-introduction
     "754146ab5979be91a3ed69c99b9dbccb4d06b6bd"
     (openpgp-fingerprint
      "D226 A339 D8DF 4481 5DDE  0CA0 3DDA 5252 7D2A C199")))))

(define-public channels
  (list asahi-channel
        guix-channel
        system-channel))

channels
