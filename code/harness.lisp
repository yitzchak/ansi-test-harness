(in-package #:ansi-test-harness)

(defun check-repo (&key directory repository)
  (format t "~:[Did not find~;Found~] ~A clone in ~A, assuming everything is okay.~%"
          #+clisp (ext:probe-directory directory)
          #-clisp (probe-file directory)
          repository directory))

(defun sync-repo (&key branch clean commit directory (git "git") repository
                  &aux (exists #+clisp (ext:probe-directory directory)
                               #-clisp (probe-file directory)))
  (cond ((and exists (not clean))
         (format t "Fetching ~A~%" repository)
         (uiop:run-program (list git "fetch" #+(or)"--quiet")
                           :output :interactive
                           :error-output :output
                           :directory directory))
        (t
         (when (and clean exists)
           (format t "Removing existing directory ~A~%" directory)
           (uiop:delete-directory-tree exists :validate t))
         (format t "Cloning ~A~%" repository)
         (uiop:run-program (list git "clone" repository (namestring directory))
                           :output :interactive
                           :error-output :output)))
  (when (or commit branch)
    (format t "Checking out ~A from ~A~%" (or commit branch) repository)
    (uiop:run-program (list git "checkout" #+(or)"--quiet" (or commit branch))
                      :output :interactive
                      :error-output :output
                      :directory directory))
  (when (and branch (not commit))
    (format t "Fast forwarding to origin/~A from ~A~%" branch repository)
    (uiop:run-program (list git "merge" "--ff-only" (format nil "origin/~A" branch))
                      :output :interactive
                      :error-output :output
                      :directory directory)))

(defun ansi-test (&key (repository "https://gitlab.common-lisp.net/ansi-test/ansi-test.git")
                       branch clean commit (git "git") skip-sync
                       ((:directory *default-pathname-defaults*) *default-pathname-defaults*)
                       ((:extrinsic-symbols cl-user::*extrinsic-symbols*) nil)
                       expected-failures (tests nil tests-p) exit)
    (declare (special cl-user::*extrinsic-symbols*))
    (if skip-sync
        (check-repo :directory *default-pathname-defaults* :repository repository)
        (sync-repo :directory *default-pathname-defaults* :repository repository
                   :git git :branch branch :clean clean :commit commit))
    (load #P"init.lsp")
    (when tests-p
      (dolist (name (mapcar (lambda (entry)
                              (uiop:symbol-call :regression-test :name entry))
                            (cdr (symbol-value (find-symbol "*ENTRIES*" :regression-test)))))
        (unless (member (symbol-name name) tests
                        :test (lambda (name prefix)
                                (alexandria:starts-with-subseq prefix name)))
          (uiop:symbol-call :regression-test :rem-test name))))
    (uiop:symbol-call :regression-test :do-tests :exit exit :expected-failures expected-failures))
