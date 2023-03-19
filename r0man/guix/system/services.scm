(define-module (r0man guix system services)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages security-token)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu services admin)
  #:use-module (gnu services auditd)
  #:use-module (gnu services avahi)
  #:use-module (gnu services base)
  #:use-module (gnu services certbot)
  #:use-module (gnu services cups)
  #:use-module (gnu services databases)
  #:use-module (gnu services desktop)
  #:use-module (gnu services docker)
  #:use-module (gnu services networking)
  #:use-module (gnu services nix)
  #:use-module (gnu services security-token)
  #:use-module (gnu services ssh)
  #:use-module (gnu services virtualization)
  #:use-module (gnu services web)
  #:use-module (gnu services web)
  #:use-module (gnu services xorg)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (r0man guix system base)
  #:use-module (r0man guix system keyboard)
  #:use-module (r0man guix system xorg)
  #:export (%auditd-service-type
            %avahi-service
            %bluetooth-service
            %certbot-service
            %cups-service
            %docker-service
            %elogind-service
            %guix-publish-service
            %http-service-burningswell
            %libvirt-service
            %nix-service
            %openssh-service
            %pcscd-service
            %postgresql-service
            %qemu-service-aarch64
            %qemu-service-x86-64
            %screen-locker-service
            %slim-service
            %udev-fido2-service
            %unattended-upgrade-service
            console-font-service-config
            guix-service-type-config))

(define %auditd-service-type
  (service auditd-service-type))

(define %avahi-service
  (service avahi-service-type))

(define %bluetooth-service
  (service bluetooth-service-type))

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
               (domains '("cuirass.burningswell.com"))
               (deploy-hook %nginx-deploy-hook))
              (certificate-configuration
               (domains '("substitutes.burningswell.com"))
               (deploy-hook %nginx-deploy-hook))
              (certificate-configuration
               (domains '("www.burningswell.com"))
               (deploy-hook %nginx-deploy-hook)))))))

(define %cups-service
  (service cups-service-type
           (cups-configuration
            (web-interface? #t)
            (extensions
             (list cups-filters)))))

(define %docker-service
  (service docker-service-type))

(define %elogind-service
  (elogind-service))

(define %guix-publish-service
  (service guix-publish-service-type
           (guix-publish-configuration
            (compression '(("zstd" 3)))
            (host "0.0.0.0")
            (port 8082))))

(define (certbot-ssl-certificate domain)
  (format #f "/etc/letsencrypt/live/~a/fullchain.pem" domain))

(define (certbot-ssl-certificate-key domain)
  (format #f "/etc/letsencrypt/live/~a/privkey.pem" domain))

(define %http-service-burningswell
  (service
   nginx-service-type
   (nginx-configuration
    (server-blocks
     (list
      (nginx-server-configuration
       (server-name '("www.burningswell.com"))
       (listen '("80"))
       ;; (ssl-certificate #f)
       ;; (ssl-certificate-key #f)
       (locations
        (list
         (nginx-location-configuration
          (uri "/")
          (body '("return 404;"))))))
      (nginx-server-configuration
       (listen '("443 ssl"))
       (server-name '("cuirass.burningswell.com"))
       (ssl-certificate (certbot-ssl-certificate "cuirass.burningswell.com"))
       (ssl-certificate-key (certbot-ssl-certificate-key "cuirass.burningswell.com"))
       (locations
        (list
         (nginx-location-configuration
          (uri "/")
          (body '("proxy_pass http://cuirass;"))))))
      (nginx-server-configuration
       (listen '("443 ssl"))
       (server-name '("substitutes.burningswell.com"))
       (ssl-certificate (certbot-ssl-certificate "substitutes.burningswell.com"))
       (ssl-certificate-key (certbot-ssl-certificate-key "substitutes.burningswell.com"))
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

(define %libvirt-service
  (service libvirt-service-type
           (libvirt-configuration
            (unix-sock-group "libvirt")
            (tls-port "16555"))))

(define %nix-service
  (service nix-service-type))

(define %openssh-service
  (service openssh-service-type
           (openssh-configuration
            (openssh openssh-sans-x)
            (permit-root-login 'prohibit-password)
            (port-number 22))))

(define %pcscd-service
  (service pcscd-service-type))

(define %postgresql-service
  (service postgresql-service-type
           (postgresql-configuration
            (postgresql postgresql-15))))

(define %qemu-service-aarch64
  (service qemu-binfmt-service-type
           (qemu-binfmt-configuration
            (platforms (lookup-qemu-platforms "x86_64")))))

(define %qemu-service-x86-64
  (service qemu-binfmt-service-type
           (qemu-binfmt-configuration
            (platforms (lookup-qemu-platforms "aarch64")))))

(define %slim-service
  (service slim-service-type
           (slim-configuration
            (xorg-configuration
             (xorg-configuration
              (keyboard-layout %keyboard-layout)
              (extra-config (list %xorg-libinput-config)))))))

(define %screen-locker-service
  (screen-locker-service xlockmore "xlock"))

(define %udev-fido2-service
  (udev-rules-service 'fido2 libfido2 #:groups '("plugdev")))

(define %unattended-upgrade-service
  (service unattended-upgrade-service-type))

(define (console-font-service-config config)
  (map (lambda (tty)
         (cons tty (file-append font-terminus "/share/consolefonts/ter-132n")))
       '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6")))

(define (guix-service-type-config config)
  (guix-configuration
   (inherit config)
   (substitute-urls
    (append (list "https://substitutes.nonguix.org")
            %default-substitute-urls))
   (authorized-keys
    (append (list (local-file "./keys/nonguix.pub")
                  (local-file "./keys/precision.pub"))
            %default-authorized-guix-keys))))
