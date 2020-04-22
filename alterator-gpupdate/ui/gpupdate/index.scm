(document:surround "/std/frame")

;;; Apply button
(define (ui-commit)
    (catch/message
        (lambda()
            (begin
                (apply woo-write
                    "/gpupdate"
                    "gp_status" (form-value "gp_status")
                    "gp_type" (form-value "gp_type")
                    (form-value-list)
                )
                (let ((data (woo-read-first "/gpupdate")))
                  (form-update-value-list '("gp_status" "gp_type") data)
                  (document:popup-information
                    (if (woo-get-option data 'gp_status)
                      (string-append
                      (_ "Group Policy management enabled for profile: ")
                        (profile-name (woo-get-option data 'gp_type)))
                      (_ "Group Policy management disabled"))
                    'ok))
            )
        )
    )
    (ui-init)
)

(define (ui-init)
    (let ((data (woo-read-first "/gpupdate")))
        (form-update-value-list '("gp_status" "gp_type") data)
        (reset-gp-type-activity)
    )
)

(define (reset-gp-type-activity)
    (if (form-value "gp_status")
        (begin (gp-type-activity   activity   #t) )
        (begin (gp-type-activity   activity   #f) )
    )
)

;;; Predefined profile names with l10n
(define profile-names
    (list
        (list "ad-domain-controller" (_ "Active Directory Domain Controller"))
        (list "workstation"          (_ "Workstation"))
        (list "server"               (_ "Server"))
    )
)

(define (profile-name profile)
    (let next-name ((names profile-names))
        (if (null? names)
            profile
            (if (equal? profile (car (car names)))
                (car (cdr (car names)))
                (next-name (cdr names))))))

(define (add-profile-radio profile)
    (radio name "gp_type" value profile text (profile-name profile) state #f))

;;; UI
(gridbox
    columns "100"
    margin 50

    (vbox align "center"
    (checkbox colspan 2 align "left" text(_ "Group Policy Management") name "gp_status" (when changed (reset-gp-type-activity)) )
    ;;; Warning if task-auth-ad and task-auth-ad-sssd is unavailable
    (document:id type-group-policy-warning (gridbox colspan 4 columns "0;100" visibility #t (label text "   ") (label
        text (string-append (bold (_ "Warning: ")) (_ "This module enables Group Policy users and computer
<br />management. Additional settings applies during boot process and
<br />user login after authentication in Active Directory.")))))
    (spacer)
    (label)

    (document:id gp-type-activity
        (gridbox activity #f
            (label text (_ "Current group policy profile:") align "left" visibility #t)
            (spacer)

            (map add-profile-radio (woo-list/name "/gpupdate/profiles"))
        )
    )

    (label)
    (if (global 'frame:next)
    (label)
    (hbox align "left"
	(document:id apply-button (button name "apply" text (_ "Apply") (when clicked (ui-commit)))))))
)

;;; Logic

(document:root
  (when loaded
    (ui-init)))
