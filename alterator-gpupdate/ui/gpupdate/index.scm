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
                    (string-append
                      (_ "Group Policy ")
                      (woo-get-option data 'gp_type))
                    'ok))
            )
        )
    )
    (ui-init)
)

(define (ui-init)
    (let ((data (woo-read-first "/gpupdate")))
        (form-update-value-list '("gp_status" "gp_type") data)

        (if (woo-get-option data 'gp_status)
            (begin (gp-type-activity   activity   #t) )
        ;;;else branch
            (begin (gp-type-activity   activity   #f) )
        )
    )
)

(define (reset-gp-type-activity)
    (if (form-value "gp_status")
        (begin (gp-type-activity   activity   #t) )
    ;;;else branch
        (begin (gp-type-activity   activity   #f) )
    )
)


;;; UI
(gridbox
    columns "100"
    margin 50

    (checkbox colspan 2 align "left" text(_ "Enable Group Policy") name "gp_status" (when changed (reset-gp-type-activity)) )
    (spacer)
    (label)

    (document:id gp-type-activity
        (gridbox activity #f
            (label text (_ "Current group policies:") align "left" visibility #t)
            (label)

            ;;; Workstation
            (radio name "gp_type" value "workstation" text (_ "Workstation") state #t)
            (label)

            ;;; Server
            (radio name "gp_type" value "server" text (_ "Server"))
            (label)
        )
    )

    (label)
    (if (global 'frame:next)
    (label)
    (hbox align "left"
	(document:id apply-button (button name "apply" text (_ "Apply") (when clicked (ui-commit))))))
)

;;; Logic

(document:root
  (when loaded
    (ui-init)))
