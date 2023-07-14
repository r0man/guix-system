(define-module (r0man guix system burningswell)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu bootloader)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services admin)
  #:use-module (gnu services avahi)
  #:use-module (gnu services base)
  #:use-module (gnu services certbot)
  #:use-module (gnu services cuirass)
  #:use-module (gnu services networking)
  #:use-module (gnu services sound)
  #:use-module (gnu services ssh)
  #:use-module (gnu services web)
  #:use-module (gnu services xorg)
  #:use-module (gnu services)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu system nss)
  #:use-module (gnu system uuid)
  #:use-module (gnu system)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (r0man guix system base)
  #:use-module (r0man guix system channels)
  #:use-module (r0man guix system keyboard)
  #:use-module (r0man guix system services)
  #:use-module (r0man guix system xorg)
  #:export (burningswell-operating-system))

(define %bootloader
  (bootloader-configuration
   (bootloader grub-bootloader)
   (keyboard-layout %keyboard-layout)
   (targets (list "/dev/sda" "/dev/sdb"))
   (terminal-outputs '(console))))

(define %nginx-deploy-hook
  (program-file
   "nginx-deploy-hook"
   #~(let ((pid (call-with-input-file "/var/run/nginx/pid" read)))
       (kill pid SIGHUP))))

(define %certbot-service
  (service certbot-service-type
           (certbot-configuration
            (email "roman@burningswell.com")
            (certificates
             (list
              (certificate-configuration
               (domains '("ci.asahi-guix.org"))
               (deploy-hook %nginx-deploy-hook))
              (certificate-configuration
               (domains '("substitutes.asahi-guix.org"))
               (deploy-hook %nginx-deploy-hook))
              (certificate-configuration
               (domains '("www.burningswell.com"))
               (deploy-hook %nginx-deploy-hook)))))))

(define %cuirass-service
  (service cuirass-service-type
           (cuirass-configuration
            (specifications
             #~(list (specification
                      (name "asahi-guix")
                      (build '(channels asahi-guix))
                      (channels
                       (cons (channel
                              (name 'asahi-guix)
                              (branch "main")
                              (url "https://github.com/r0man/asahi-guix.git"))
                             %default-channels))
                      (systems '("aarch64-linux" "x86_64-linux")))
                     (specification
                      (name "asahi-guix-next")
                      (build '(channels asahi-guix))
                      (channels
                       (cons (channel
                              (name 'asahi-guix)
                              (branch "next")
                              (url "https://github.com/r0man/asahi-guix.git"))
                             %default-channels))
                      (systems '("aarch64-linux" "x86_64-linux")))))
            (use-substitutes? #t)
            (remote-server (cuirass-remote-server-configuration)))))

(define %cuirass-remote-worker-service
  (service cuirass-remote-worker-service-type
           (cuirass-remote-worker-configuration
            (systems '("aarch64-linux" "x86_64-linux"))
            (workers 2))))

(define %http-service
  (service
   nginx-service-type
   (nginx-configuration
    (server-blocks
     (list
      (nginx-server-configuration
       (ssl-certificate (certbot-ssl-certificate "www.burningswell.com"))
       (ssl-certificate-key (certbot-ssl-certificate-key "www.burningswell.com"))
       (locations
        (list
         (nginx-location-configuration
          (uri "/")
          (body '("return 404;"))))))
      (nginx-server-configuration
       (server-name '("ci.asahi-guix.org"))
       (listen '("443 ssl"))
       (ssl-certificate (certbot-ssl-certificate "ci.asahi-guix.org"))
       (ssl-certificate-key (certbot-ssl-certificate-key "ci.asahi-guix.org"))
       (locations
        (list
         (nginx-location-configuration
          (uri "~ ^/admin")
          (body (list "if ($ssl_client_verify != SUCCESS) { return 403; } proxy_pass http://cuirass;")))
         (nginx-location-configuration
          (uri "/")
          (body '("proxy_pass http://cuirass;"))))))
      (nginx-server-configuration
       (server-name '("substitutes.asahi-guix.org"))
       (listen '("443 ssl"))
       (ssl-certificate (certbot-ssl-certificate "substitutes.asahi-guix.org"))
       (ssl-certificate-key (certbot-ssl-certificate-key "substitutes.asahi-guix.org"))
       (locations
        (list
         (nginx-location-configuration
          (uri "/")
          (body '("proxy_pass http://guix-publish;"))))))))
    (upstream-blocks
     (list (nginx-upstream-configuration
            (name "cuirass")
            (servers (list "localhost:8081")))
           (nginx-upstream-configuration
            (name "guix-publish")
            (servers (list "localhost:8082"))))))))

(define %unattended-upgrade-service
  (service unattended-upgrade-service-type
           (unattended-upgrade-configuration
            (channels #~(list (channel
                               (name 'asahi)
                               (url "https://github.com/r0man/asahi-guix.git")
                               (branch "main")
                               (introduction
                                (make-channel-introduction
                                 "c11f1c583d11b1ed55d34d7041b0c12d51d573e4"
                                 (openpgp-fingerprint
                                  "D226 A339 D8DF 4481 5DDE  0CA0 3DDA 5252 7D2A C199"))))

                              (channel
                               (name 'guix)
                               (url "https://git.savannah.gnu.org/git/guix.git")
                               (branch "master")
                               (introduction
                                (make-channel-introduction
                                 "9edb3f66fd807b096b48283debdcddccfea34bad"
                                 (openpgp-fingerprint
                                  "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))

                              (channel
                               (name 'r0man-system)
                               (url "/root/guix-system")
                               (branch "main")
                               (introduction
                                (make-channel-introduction
                                 "754146ab5979be91a3ed69c99b9dbccb4d06b6bd"
                                 (openpgp-fingerprint
                                  "D226 A339 D8DF 4481 5DDE  0CA0 3DDA 5252 7D2A C199")))))))))

(define %mapped-devices
  (list (mapped-device
         (source (list "/dev/sda2" "/dev/sdb2"))
         (target "/dev/md0")
         (type raid-device-mapping))))

(define %file-systems
  (cons (file-system
          (mount-point "/")
          (device (file-system-label "root"))
          (type "ext4")
          (dependencies %mapped-devices))
        %base-file-systems))

(define %packages
  (cons* (operating-system-packages base-operating-system)))

(define %services
  (cons* %avahi-service
         %certbot-service
         %cuirass-remote-worker-service
         %cuirass-service
         %docker-service
         %elogind-service
         %guix-publish-service
         %http-service
         %postgresql-service
         %qemu-service-x86-64
         %udev-fido2-service ;; TODO: Remove
         %unattended-upgrade-service
         (service static-networking-service-type
                  (list (static-networking
                         (addresses
                          (list (network-address
                                 (device "eth0")
                                 (value "136.243.174.102/26"))))
                         (routes
                          (list (network-route
                                 (destination "default")
                                 (gateway "136.243.174.65"))))
                         (name-servers '("1.1.1.1" "8.8.8.8")))))
         (operating-system-user-services base-operating-system)))

(define %swap-devices
  (list (swap-space (target "/swapfile"))))

(define burningswell-operating-system
  (operating-system
    (inherit base-operating-system)
    (host-name "burningswell")
    (kernel linux-libre)
    ;; (firmware %firmware)
    (initrd-modules (cons "raid1" %base-initrd-modules))
    (bootloader %bootloader)
    (mapped-devices %mapped-devices)
    (file-systems %file-systems)
    (packages %packages)
    (services %services)
    (swap-devices %swap-devices)))

burningswell-operating-system
