;; (defun audience-ball-in-court-open-mew-message-at-point ()
;;  "Jump to a line according to the number which is given"
;;  (interactive)
;;  (let ((msg (thing-at-point 'word)))
;;   (switch-to-buffer (get-buffer "%inbox"))
;;   (while (not (string-match mew-regex-message-files3 msg))
;;    (setq msg (read-string "Message No.: " "")))
;;   (when (mew-summary-search-msg msg)
;;    (if mew-summary-goto-line-then-display
;;     (mew-summary-display)))))
