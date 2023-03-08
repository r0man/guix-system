(define-module (r0man guix system channels)
  #:use-module (guix channels))

(define channels
  (list (channel
         (name 'asahi)
         (url "https://github.com/r0man/asahi-guix.git")
         (branch "main")
         (commit "93959130b366875edac1b3e45793bfefb970daf0")
         (introduction
          (make-channel-introduction
           "c11f1c583d11b1ed55d34d7041b0c12d51d573e4"
           (openpgp-fingerprint
            "D226 A339 D8DF 4481 5DDE  0CA0 3DDA 5252 7D2A C199"))))

        ;; (channel
        ;;  (name 'guix)
        ;;  (url "https://git.savannah.gnu.org/git/guix.git")
        ;;  (branch "master")
        ;;  (commit "7833acab0da02335941974608510c02e2d1d8069")
        ;;  (introduction
        ;;   (make-channel-introduction
        ;;    "9edb3f66fd807b096b48283debdcddccfea34bad"
        ;;    (openpgp-fingerprint
        ;;     "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))

        (channel
         (name 'guix)
         (url "https://github.com/r0man/guix.git")
         (branch "x-wrapper")
         (commit "14dfe8be59ef5cda15540b22cf0cbcb2f6681b29")
         (introduction
          (make-channel-introduction
           "9edb3f66fd807b096b48283debdcddccfea34bad"
           (openpgp-fingerprint
            "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))

        (channel
         (name 'nonguix)
         (url "https://gitlab.com/nonguix/nonguix")
         (branch "master")
         (commit "19ef3a8741af9957f372859bab894c3ce0c94f15")
         (introduction
          (make-channel-introduction
           "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
           (openpgp-fingerprint
            "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))

        (channel
         (name 'r0man-channel)
         (url "https://github.com/r0man/guix-channel.git")
         (branch "main")
         (commit "9ae2ee4d41dafe01a42f21b925db1e4100eeb93a")
         (introduction
          (make-channel-introduction
           "8eb7a76af9b51b80f5c01f18639e6360833fc377"
           (openpgp-fingerprint
            "D226 A339 D8DF 4481 5DDE  0CA0 3DDA 5252 7D2A C199"))))

        (channel
         (name 'r0man-system)
         (url "git@github.com:r0man/guix-system.git")
         (branch "main")
         (commit "f81d4e89ff691788d00161d6b45db0ecc8819d6d")
         (introduction
          (make-channel-introduction
           "754146ab5979be91a3ed69c99b9dbccb4d06b6bd"
           (openpgp-fingerprint
            "D226 A339 D8DF 4481 5DDE  0CA0 3DDA 5252 7D2A C199"))))))

channels
