(global-set-key "\C-caucn" 'audience-call-number-at-point)
(global-set-key "\C-caucp" 'audience-call-person-at-point)
(global-set-key "\C-crerq" 'audience-record-question)

(defun audience-bbdb-insert-last-contacted-timestamp ()
 ""
 (interactive)
 (bbdb-delete-last-contacted)
 (bbdb-insert-new-field
  (bbdb-current-record t)
  (intern "last-contacted")
  (current-date-and-time)))

(defun bbdb-delete-last-contacted ()
 "Delete the line which the cursor is on; actually, delete the field which
that line represents from the database.  If the cursor is on the first line
of a database entry (the name/company line) then the entire entry will be
deleted."
  (let* ((records (list (bbdb-current-record)))
	(noprompt t)
	(field '(property (last-contacted . "")))
	(type (car field))
	record
	(name (cond ((null field) (error "on an unfield"))
	       ((eq type 'property) (symbol-name (car (nth 1 field))))
	       (t (symbol-name type)))))
  (while records
   (setq record (car records))
   (if (eq type 'name)
    (bbdb-delete-current-record record noprompt)
    (if (not (or noprompt
	      (bbdb-y-or-n-p (format "delete this %s field (of %s)? "
			      name
			      (bbdb-record-name record)))))
     nil
     (cond ((memq type '(phone address))
	    (bbdb-record-store-field-internal
	     record type
	     (delq (nth 1 field)
	      (bbdb-record-get-field-internal record type))))
      ((memq type '(net aka))
       (let ((rest (bbdb-record-get-field-internal record type)))
	(while rest
	 (bbdb-remhash (downcase (car rest)) record)
	 (setq rest (cdr rest))))
       (bbdb-record-store-field-internal record type nil))
      ((eq type 'property)
       (bbdb-record-putprop record (car (nth 1 field)) nil))
      (t (error "doubleplus ungood: unknown field type")))
     (bbdb-change-record record nil)
     (bbdb-redisplay-one-record record)))
   (setq records (cdr records)))))

(defun audience-call-number-at-point (where)
 ""
 (interactive "d")
 (audience-call-number (audience-phone-number-at-point-approximately where)))

(defun audience-call-person ()
 ""
 (interactive)
 (let* ((name (read-from-minibuffer "Please enter a person's name: "))
	(phone-rec (car (bbdb-record-phones (car (bbdb-search (bbdb-records) name))))))
  (audience-call-number (concat "001" (int-to-string (elt phone-rec 1)) (int-to-string (elt phone-rec 2)) (int-to-string (elt phone-rec 3))))))

(defun audience-call-person-at-point ()
 ""
 (interactive)
 (let* ((name (org-frdcsa-manager-dialog-choose
	       (emacs-nlp-named-entity-at-point-helper-function-get-names
		(emacs-nlp-named-entity-at-point))))
	(phone-rec (car (bbdb-record-phones (car (bbdb-search (bbdb-records) name))))))
  (audience-call-number (concat "001" (int-to-string (elt phone-rec 1)) (int-to-string (elt phone-rec 2)) (int-to-string (elt phone-rec 3))))))

(defun audience-call-number (number)
 ""
 (let* ((command (concat "twinkle --call " number " &")))
  (if
   (not (string= number ""))
   (progn
    (if (string= 
	 (buffer-name)
	 "*BBDB*"
	 )
     (audience-bbdb-insert-last-contacted-timestamp))
    (shell-command command)
    (message command)))))

(defun audience-phone-number-at-point-approximately (where)
 ""
 (interactive)
 (let
  ((text (buffer-substring-no-properties (progn (goto-char where) (move-beginning-of-line nil) (point)) (progn (move-end-of-line nil) (point)))))
  (string-match "\\(\\(([2-9][0-9][0-9])[-. ]?\\|[2-9][0-9][0-9][-. ]\\)?[0-9][0-9][0-9][-. ][0-9][0-9][0-9][0-9]\\( *\\(x\\|ext\\.?\\) *[0-9]+\\)?\\)" text)
  (audience-prepare-phone-number (match-string 1 text))
  )
 )

(defun audience-prepare-phone-number (text)
 "clean out non-digit numbers and append 001 and area code if
necessary"
 (interactive)
 (while (string-match "[^0-9]" text)
  (setq text (replace-match "" nil nil text)))
 (if (= (length text) 7)
  (setq text (concat "630" text)))
 (concat "001" text))


;; ;; To execute Mew, the fgs are necessary either in the site




;; ;;  configuration file or in your "~/.emacs".

;; (autoload 'mew "mew" nil t)
;; (autoload 'mew-send "mew" nil t)

;; ;; ;; Optional setup (Read Mail menu for Emacs 21):
;; ;; (if (boundp 'read-mail-command)
;; ;;     (setq read-mail-command 'mew))

;; ;; ;; Optional setup (e.g. C-xm for sending a message):
;; (autoload 'mew-user-agent-compose "mew" nil t)
;; (if (boundp 'mail-user-agent)
;;     (setq mail-user-agent 'mew-user-agent))
;; (if (fboundp 'define-mail-user-agent)
;;     (define-mail-user-agent
;;       'mew-user-agent
;;       'mew-user-agent-compose
;;       'mew-draft-send-message
;;       'mew-draft-kill
;;       'mew-send-hook))

;; ;; If you are using Emacs with the --unibyte option or the EMACS_UNIBYTE
;; ;; environment variable for Latin-1, put the following into your
;; ;; ~/.emacs".

;; ;;      (set-language-environment "Latin-1")
;; ;;      (set-input-method "latin-1-prefix") ;; or "latin-1-postfix"

;; ;; If you use the following configuration for Latin-1, please remove it.
;; ;; This is an obsolete handling of Latin-1 that can cause Mew to function
;; ;; incorrectly.

;; ;;      (standard-display-european 1)

;; ;; When booting, Mew reads the file "~/.mew.el". All Mew configurations
;; ;; should be written in this file.

;; ;; To configure your e-mail address, the followings are necessary.

;; (setq mew-name "Andrew Dougherty") ;; (user-full-name)
;; (setq mew-user "andrewd") ;; (user-login-name)
;; (setq mew-mail-domain "onshore.com")

;; ;; To send e-mail messages by SMTP, the following is necessary.

;; (setq mew-smtp-server "queso.onshore.com")  ;; if not localhost

;; ;; If you want to use POP to receive e-mail messages, the followings are
;; ;; necessary.

;; ;; (setq mew-pop-user "your POP account")  ;; (user-login-name)
;; ;; (setq mew-pop-server "your POP server")    ;; if not localhost

;; ;; If you want to use a local mailbox to receive e-mail messages, the
;; ;; followings are necessary.

;; ;;      ;; To use local mailbox "mbox" or "maildir" instead of POP
;; ;;      (setq mew-mailbox-type 'mbox)
;; ;;      (setq mew-mbox-command "incm")
;; ;;      (setq mew-mbox-command-arg "-u -d /path/to/mbox")
;; ;;      ;; If /path/to/mbox is a file, it means "mbox".
;; ;;      ;; If /path/to/mbox is a directory, it means "maildir".

;; ;; If you want to use IMAP to receive e-mail messages, the followings are
;; ;; necessary.

;; (setq mew-proto "%")
;; (setq mew-imap-user "andrewd")  ;; (user-login-name)
;; (setq mew-imap-server "queso.onshore.com")    ;; if not localhost

;; ;; To read and/or write articles of NetNews, the followings are
;; ;; necessary.

;; ;; (setq mew-nntp-user "your NNTP account")
;; ;;     (setq mew-nntp-server "your NNTP server")

;; (setq mew-rc-file "~/.emacs.d/.mew.el")
;; (autoload 'mew "mew" nil t)
;; (autoload 'mew-send "mew" nil t)
;; (setq mew-use-cached-passwd t)
;; (if (boundp 'read-mail-command)
;;     (setq read-mail-command 'mew))
;; (autoload 'mew-user-agent-compose "mew" nil t)
;; (if (boundp 'mail-user-agent)
;;     (setq mail-user-agent 'mew-user-agent))
;; (if (fboundp 'define-mail-user-agent)
;;     (define-mail-user-agent
;;       'mew-user-agent
;;       'mew-user-agent-compose
;;       'mew-draft-send-message
;;       'mew-draft-kill
;;       'mew-send-hook))
;; (setq mew-pop-size 0)
;; (setq mew-smtp-auth-list nil)
;; (setq toolbar-mail-reader 'Mew)
;; (set-default 'mew-decode-quoted 't) 
;; (setq mew-use-unread-mark t)

(load "/var/lib/myfrdcsa/codebases/internal/audience/systems/twitter/audience-twitter.el")
(load "/var/lib/myfrdcsa/codebases/internal/audience/systems/irc/audience-erc.el")
(load "/var/lib/myfrdcsa/codebases/internal/audience/frdcsa/emacs/las.el")
(load "/var/lib/myfrdcsa/codebases/internal/audience/frdcsa/emacs/ball-in-court.el")
(load "/var/lib/myfrdcsa/codebases/internal/audience/frdcsa/emacs/mps.el")

(defun audience-record-question ()
 ""
 (interactive)
 (ffap "/home/andrewdo/.do/questions.notes"))
