(define-module (r0man guix system channels)
  #:use-module (guix channels))

(define channels
  (list (channel
         (name 'asahi)
         (url "https://github.com/r0man/asahi-guix.git")
         ;; (branch "main")
         (branch "next-release")
         ;; (commit "2e178b253243719b60a4ff6da2067696d66ac7a2")
         (introduction
          (make-channel-introduction
           "c11f1c583d11b1ed55d34d7041b0c12d51d573e4"
           (openpgp-fingerprint
            "D226 A339 D8DF 4481 5DDE  0CA0 3DDA 5252 7D2A C199"))))

        (channel
         (name 'guix)
         (url "https://git.savannah.gnu.org/git/guix.git")
         (branch "master")
         (commit "04724e59971b03f86a410285653d24005c62b924")
         (introduction
          (make-channel-introduction
           "9edb3f66fd807b096b48283debdcddccfea34bad"
           (openpgp-fingerprint
            "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))

        (channel
         (name 'r0man-system)
         (url "git@github.com:r0man/guix-system.git")
         ;; (branch "main")
         (branch "next-release")
         (introduction
          (make-channel-introduction
           "754146ab5979be91a3ed69c99b9dbccb4d06b6bd"
           (openpgp-fingerprint
            "D226 A339 D8DF 4481 5DDE  0CA0 3DDA 5252 7D2A C199"))))))

channels
