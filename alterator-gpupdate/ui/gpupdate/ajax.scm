(define-module (ui gpupdate ajax)
    :use-module (alterator ajax)
    :use-module (alterator woo)
    :export (init))

(define (ui-read)
  (form-update-enum "gp_type" (woo-list "/gpupdate/profiles"))
  (form-update-value-list '("gp_status" "gp_type") (woo-read-first "/gpupdate" 'language (form-value "language"))))

(define (ui-write)
  (catch/message
    (lambda()
      (woo-write "/gpupdate"
                 'gp_status (form-value "gp_status")
                 'gp_type (form-value "gp_type")
                 )))
  (ui-read))

(define (init)
  (ui-read)
  (form-bind "submit" "click" ui-write)
  (form-bind "reset" "click" ui-read))
