(cl:in-package #:asdf-user)

(defsystem #:ansi-test-harness
  :description "Harness for ansi-test"
  :license "MIT"
  :author "Tarn W. Burton"
  :version "0.1.0"
  :homepage "https://github.com/yitzchak/ansi-test-harness"
  :bug-tracker "https://github.com/yitzchak/ansi-test-harness/issues"
  :depends-on (#:alexandria)
  :components ((:module code
                :serial t
                :components ((:file "packages")
                             (:file "harness")))))
