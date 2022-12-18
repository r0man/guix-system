(use-modules (gnu))
(use-service-modules networking ssh)
(use-package-modules screen ssh)

(define bombaclaat
  (operating-system
    (host-name "bombaclaat")
    (timezone "Europe/Berlin")
    (locale "en_US.utf8")

    ;; Boot in "legacy" BIOS mode, assuming /dev/sdX is the
    ;; target hard disk, and "my-root" is the label of the target
    ;; root file system.
    (bootloader (bootloader-configuration
                 (bootloader grub-bootloader)
                 (target "/dev/sdX")))
    (file-systems (cons (file-system
                          (device (file-system-label "my-root"))
                          (mount-point "/")
                          (type "ext4"))
                        %base-file-systems))

    ;; This is where user accounts are specified.  The "root"
    ;; account is implicit, and is initially created with the
    ;; empty password.
    (users (cons (user-account
                  (name "alice")
                  (comment "Bob's sister")
                  (group "users")

                  ;; Adding the account to the "wheel" group
                  ;; makes it a sudoer.  Adding it to "audio"
                  ;; and "video" allows the user to play sound
                  ;; and access the webcam.
                  (supplementary-groups '("wheel"
                                          "audio" "video")))
                 %base-user-accounts))

    ;; Globally-installed packages.
    (packages (cons screen %base-packages))

    ;; Add services to the baseline: a DHCP client and
    ;; an SSH server.
    (services (append (list (service dhcp-client-service-type)
                            (service openssh-service-type
                                     (openssh-configuration
                                      (openssh openssh-sans-x)
                                      (port-number 2222))))
                      %base-services))))

bombaclaat
