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
                  (form-update-value-list '("gp_status" "gp_profile_name") data)
                  (document:popup-information
                    (if (woo-get-option data 'gp_status)
                      (string-append
                      (_ "Group Policy management<br />enabled for profile: ")
                        "<br /><br /><b>" (woo-get-option data 'gp_profile_name) "</b><br />")
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

(define (add-profile-radio profile)
    (radio name "gp_type" value (woo-get-option profile 'name) text (woo-get-option profile 'label) state #f))

;;; UI
(gridbox
    columns "100"
    margin 50

    (vbox align "center"
    (checkbox colspan 2 align "left" text(_ "Group Policy Management") name "gp_status" (when changed (reset-gp-type-activity)) )
    ;;; Warning if task-auth-ad and task-auth-ad-sssd is unavailable
    (document:id type-group-policy-warning (gridbox colspan 4 columns "0;100" visibility #t (label text "   ") (label
        text (string-append (bold (_ "Warning: "))
            (_ "This module enables Group Policy users and computer") "<br />"
            (_ "management. Additional settings applies during boot process and") "<br />"
            (_ "user login after authentication in Active Directory.")))))
    (spacer)
    (label)

    (document:id gp-type-activity
        (gridbox activity #f
            (label text (_ "Current group policy profile:") align "left" visibility #t)
            (spacer)

            (map add-profile-radio (woo-list "/gpupdate/profiles" 'language (form-value "language")))
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
