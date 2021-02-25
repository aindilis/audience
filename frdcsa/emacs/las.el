(global-set-key "\C-caA" 'audience-add-person)
(global-set-key "\C-caR" 'audience-remove-person)
(global-set-key "\C-caug" 'audience-add-group)
(global-set-key "\C-cauG" 'audience-remove-group)
(global-set-key "\C-cae" 'audience-las-edit-letter)
(global-set-key "\C-can" 'audience-las-next-letter)
(global-set-key "\C-cas" 'audience-las-send-letter)
(global-set-key "\C-caq" 'audience-las-squash-paragraph-into-line)
(global-set-key "\C-ca+" 'audience-las-insert-item)
(global-set-key "\C-cam" 'audience-edit-memcon)
(global-set-key "\C-caM" 'audience-next-memcon)
(global-set-key "\C-cat" 'audience-edit-talking-points)
(global-set-key "\C-caT" 'audience-next-talking-points)
(global-set-key "\C-cap" 'audience-edit-poem)
(global-set-key "\C-caP" 'audience-next-poem)
;; (global-set-key "\C-cao" 'audience-ball-in-court-open-mew-message-at-point)

(setq audience-person-directory "/var/lib/myfrdcsa/codebases/internal/socbot/data/<REDACTED>")
(setq audience-group-directory "/var/lib/myfrdcsa/codebases/internal/socbot/data/<REDACTED>")

(setq audience-las-minibuffer-map (copy-keymap minibuffer-local-map))
(define-key audience-las-minibuffer-map "\t" 'bbdb-complete-name)

(defun audience-test ()
 ""
 (interactive)
 (message "hello")
 (sit-for 3.0))

(setq audience-letter-directory
 "~/.config/frdcsa/audience/las/letters")

(setq audience-memcon-directory
 "~/.config/frdcsa/audience/las/memcons")

(setq audience-talking-points-directory
 "~/.config/frdcsa/audience/las/talking-points")

(setq audience-poem-directory
 "~/.config/frdcsa/audience/las/poems")

(defun audience-edit-memcon ()
 "Create a new memcon"
 (interactive)
 (find-file (audience-select-latest "memcon-" audience-memcon-directory))
 (end-of-buffer))

(defun audience-next-memcon ()
 "Create a new memcon"
 (interactive)
 (audience-select-latest "memcon-" audience-memcon-directory)
 (find-file audience-next-item)
 (insert (concat "(Memcon with " audience-current-audience ")\n("))
 (insert-user-datestamp 1)
 (insert ")\n\n()")
 (backward-char)
 (save-buffer))

(defun audience-edit-talking-points ()
 "Create new talking points"
 (interactive)
 (find-file (audience-select-latest "talking-points-" audience-talking-points-directory))
 (end-of-buffer))

(defun audience-next-talking-points ()
 "Create new talking points"
 (interactive)
 (audience-select-latest "talking-points-" audience-talking-points-directory)
 (find-file audience-next-item)
 (insert (concat "Talking points with " audience-current-audience "\n"))
 (insert-user-datestamp 1)
 (insert "\n\n")
 (save-buffer)
 (end-of-buffer))

(defun audience-edit-poem ()
 "Create a new poem"
 (interactive)
 (find-file (audience-select-latest "poem-" audience-poem-directory))
 (end-of-buffer))

(defun audience-next-poem ()
 "Create a new poem"
 (interactive)
 (audience-select-latest "poem-" audience-poem-directory)
 (find-file audience-next-item)
 (insert (concat "Poem with " audience-current-audience "\n"))
 (insert-user-datestamp 1)
 (insert "\n\n")
 (save-buffer)
 (end-of-buffer))

(defun audience-insert-header ()
 (string-match "\\(.*?\\)-"
  audience-las-current-audience)
 (insert (concat "Hey " (match-string 1 audience-las-current-audience)
	  ",\n\n"))
 (backward-word 1)
 (capitalize-word 1))

(defun audience-add-person ()
 "Add a person to the system (simple script)"
 (interactive)
 (bbdb-create))

;; (defun socbot-edit-persons-profile ()
;;  "Add a person to the system (simple script)"
;;  (interactive)
;;  (let* ((person (audience-select-audience)))
;;   (find-file (concat audience-person-directory "/" person "/profile"))))

;; (defun socbot-edit-persons-profile-dir ()
;;  "Run dired on a person's profile directory)"
;;  (interactive)
;;  (let* ((person (audience-select-audience)))
;;   (dired (concat audience-person-directory "/" person))))

;; (defun socbot-insert-persons-profile-dir ()
;;  ""
;;  (interactive)
;;  (let* ((person (audience-select-audience)))
;;   (insert (concat audience-person-directory "/" person))))

(defun audience-add-group ()
 "Add a person to the system (simple script)"
 (interactive)
 (error "not implemented"))


(defun audience-remove-person ()
 "Add a person to the system (simple script)"
 (interactive)
 (error "not implemented"))

(defun audience-remove-group ()
 "Add a person to the system (simple script)"
 (interactive)
 (error "not implemented"))


(defun audience-las-edit-letter ()
 "Add an item  to the latest letter going to a  specific group, so for
instance, if  you want to tell  all the Frdcsa  members something, you
just run this command and then enter what you want to tell them.  This
command  is  temporary in  the  sense that  a  much  better system  is
anticipated.  Of course, in lieu we make due."
 (interactive)
 (find-file (audience-las-select-latest-letter))
 (end-of-buffer))

(defun audience-las-insert-item ()
 "Add an item  to the latest letter going to a  specific group, so for
instance, if  you want to tell  all the Frdcsa  members something, you
just run this command and then enter what you want to tell them.  This
command  is  temporary in  the  sense that  a  much  better system  is
anticipated.  Of course, in lieu we make due."
 (interactive)
 (find-file (audience-las-select-latest-letter))
 (end-of-buffer)
 (delete-blank-lines)
 (insert "\n((")
 (insert-user-datestamp t)
 (insert ")\n\t+ )\n")
 (backward-char 2))

(defun audience-las-send-letter ()
 "Function to indicate that a letter should be sent."
 (interactive)
 (let* ((name (buffer-name (current-buffer)))
	(recipient (progn
		    (string-match "^letter-to-\\(.*\\)\\.[0-9]+$" name)
		    (match-string 1 name)))
	(contents (buffer-string)))
  (message (concat "<" recipient ">"))
					; (audience-las-edit-letter)
  (unless (string= recipient "")
   (save-buffer)
   (kill-buffer (current-buffer))
   (message (concat "Preparing to send letter..."))
   (compose-mail recipient (read-from-minibuffer "Subject: "))
   (end-of-buffer)
   (insert contents)
   (ispell-buffer)
					; (insert (concat
					; "\n\n\nOfficial Communique of the FRDCSA\n"))
					; (find-file audience-las-next-letter)
					; (audience-insert-header)
					; (end-of-buffer)
					; (save-buffer)
					; (kill-buffer (current-buffer))
   )
  )
 )

;; (defun audience-las-send-letter ()
;;  "Function to indicate that a letter should be sent."
;;  (interactive)
;;  (audience-las-edit-letter)
;;  (message (concat "Preparing to send letter..."))
;;  (ispell-buffer)
;;  (end-of-buffer)
;;  (insert (concat
;; 	  "\n\n\nOfficial Communique of the FRDCSA\n"))
;;  (find-file audience-las-next-letter)
;;  (audience-insert-header)
;;  (end-of-buffer)
;;  (save-buffer)
;;  (kill-buffer (current-buffer)))

(defun audience-las-next-letter ()
 "Function to indicate that a letter should be sent."
 (interactive)
 (audience-las-edit-letter)
 (find-file audience-las-next-letter)
 (audience-insert-header)
 (end-of-buffer)
 (save-buffer))

(defun audience-las-select-latest-letter ()
 "Choose the latest file to be sent"
 (let*
  ((audience-las-letters-dir audience-letter-directory)
   (audience
    (setq audience-las-current-audience (audience-select-audience)))
   (i 0)
   (letter
    (if (not (file-exists-p
	      (concat audience-las-letters-dir "/letter-to-" audience "-0.do")))
     (progn
      (setq audience-las-next-letter
       (concat audience-las-letters-dir "/letter-to-" audience "-1.do"))
      (concat audience-las-letters-dir "/letter-to-" audience "-0.do"))
     (progn
      (while
       (file-exists-p
	(concat audience-las-letters-dir "/letter-to-" audience "-" (format "%d" i) ".do"))
       (setq i (1+ i)))
      (progn
       (setq audience-las-next-letter
	(concat audience-las-letters-dir "/letter-to-" audience "-" (format "%d" i)))
       (concat audience-las-letters-dir "/letter-to-" audience "-" (format "%d" (1- i)) ".do"))))))
  letter))

(defun audience-select-latest (prefix directory)
 "Choose the latest file to be sent"
 (let*
  ((audience
    (setq audience-current-audience (audience-select-audience)))
   (i 0)
   (item
    (if (not (file-exists-p
	      (concat directory "/" prefix audience "-0.do")))
     (progn
      (setq audience-next-item
       (concat directory "/" prefix audience "-1.do"))
      (concat directory "/" prefix audience "-0.do"))
     (progn
      (while
       (file-exists-p
	(concat directory "/" prefix audience "-" (format "%d" i) ".do"))
       (setq i (1+ i)))
      (progn
       (setq audience-next-item
	(concat directory "/" prefix audience "-" (format "%d" i) ".do"))
       (concat directory "/" prefix audience "-" (format "%d" (1- i)) ".do"))))))
  item))

(defun audience-las-select-latest-letter-orig ()
 "Choose the latest file to be sent"
 (let*
  ((audience-las-letters-dir audience-letter-directory)
   (audience
    (setq audience-las-current-audience (audience-select-audience)))
   (i 0)
   (letter
    (if (not (file-exists-p
	      (concat audience-las-letters-dir "/letter-to-" audience ".0")))
     (progn
      (setq audience-las-next-letter
       (concat audience-las-letters-dir "/letter-to-" audience ".1"))
      (concat audience-las-letters-dir "/letter-to-" audience ".0"))
     (progn
      (while
       (file-exists-p
	(concat audience-las-letters-dir "/letter-to-" audience "." (format "%d" i)))
       (setq i (1+ i)))
      (progn
       (setq audience-las-next-letter
	(concat audience-las-letters-dir "/letter-to-" audience "." (format "%d" i)))
       (concat audience-las-letters-dir "/letter-to-" audience "." (format "%d" (1- i))))))))
  letter))

(defun audience-select-latest-orig (prefix directory)
 "Choose the latest file to be sent"
 (let*
  ((audience
    (setq audience-current-audience (audience-select-audience)))
   (i 0)
   (item
    (if (not (file-exists-p
	      (concat directory "/" prefix audience ".0")))
     (progn
      (setq audience-next-item
       (concat directory "/" prefix audience ".1"))
      (concat directory "/" prefix audience ".0"))
     (progn
      (while
       (file-exists-p
	(concat directory "/" prefix audience "." (format "%d" i)))
       (setq i (1+ i)))
      (progn
       (setq audience-next-item
	(concat directory "/" prefix audience "." (format "%d" i)))
       (concat directory "/" prefix audience "." (format "%d" (1- i))))))))
  item))

;; (read-from-minibuffer "Enter Contact (tab to complete) " "To: " bbdb-complete-name)

(defun audience-select-audience (&optional dirs)
 "program to select a directory"
 (interactive "S")
 (let ((name (read-from-minibuffer "Enter Contact (tab to complete) " "To: " audience-las-minibuffer-map)))
  (string-match "^To: \\(.*\\)" name)
  (match-string 1 name)))

(defun audience-las-squash-paragraph-into-line ()
 "Take a paragraph and remove all carriage returns, etc."
 (interactive)
 (forward-word 1)
 (backward-word 1)
 (fill-paragraph nil)
 (let*
  ((start (point))
   (end (progn
	 (forward-paragraph)
	 (point))))
  (narrow-to-region start end)
  (goto-char start)
  (while (< (point) end)
   (end-of-line)
   (delete-char 1)
   (delete-horizontal-space)
   (insert " "))
  (delete-horizontal-space)
  (insert "\n")
  (widen)))

;; (setq last-kbd-macro
;;  [?\M-> ?\C-r ?> ?> ?\C-  ?\C-e ?\C-f ?\C-  ?\M-> ?\C-x ?n ?n ?\M-< ?\M-x ?a ?u ?d ?i ?e ?n ?c ?e ?- ?l ?a ?s ?- ?s ?q tab return ?\C-x ?n ?w])
