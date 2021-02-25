;; (setq vm-imap-server-list
;;  '(
;;    "imap:ai.onshore.com:143:inbox:login:andrewd:*"
;;    ))

;; ;; MEW CONFIGURATION

;; ;; To execute Mew, the followings are necessary either in the site
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

