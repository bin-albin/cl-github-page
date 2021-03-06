(in-package :cl-github-page)

(defparameter *blog-conf* "blog.json")
(defparameter *verbose* t)

(defun read-posts-date (path)
  (with-open-file (s path)
    (read s)))

(defun string-concat (s1 s2)
  (concatenate 'string s1 s2))

;;; Public

(defun create (&optional (blog-dir *blog-dir*))
  "Creates a directory to be used as the local blog."
  (ensure-directories-exist blog-dir)
  (let ((src (string-concat blog-dir "src/"))
	(posts (string-concat blog-dir "posts/"))
	(tags (string-concat blog-dir "tags.lisp"))
	(friends (string-concat blog-dir "friends.lisp")))
    (ensure-directories-exist src)
    (ensure-directories-exist posts)
    (unless (probe-file tags)
      (with-open-file (s tags :direction :output)
	(print '() s)
	(format t "Creates the tags.lisp~%")))
    (unless (probe-file friends)
      (with-open-file (s friends :direction :output)
	(print '() s)
	(format t "Creates the friends.lisp~%")))))

(defun main (&key
               (config (cl-fad:merge-pathnames-as-file (user-homedir-pathname) *blog-conf*))
               (forced-p nil)
               (verbose nil))
  (let* ((conf (config-parse config))
         (*about-me* (config-about-me conf))
         (*about-me-src* (config-about-me-src conf))
         (*about-me-tmpl* (config-tmpl-about-me conf))
         (*atom* (config-atom conf))
         (*atom-tmpl* (config-tmpl-atom conf))
         (*blog-dir* (config-dir-blog conf))
         (*blog-title-tmpl* (config-blog-title conf))
         (*friends* (config-friends conf))
         (*index* (config-index conf))
         (*index-tmpl* (config-tmpl-index conf))
         (*post-tmpl* (config-tmpl-post conf))
         (*posts-dir* (config-dir-dest conf))
         (*sources-dir* (config-dir-src conf))
         (*tags* (config-tags conf))
         (*verbose* verbose))
    (clrhash *categories*)
    (let* ((*posts-date* (read-posts-date (config-posts-date conf)))
           (srcs (get-all-sources conf)))
      (update-all-posts srcs forced-p)
      (write-rss srcs)
      (write-about-me)
      (write-index srcs))))
