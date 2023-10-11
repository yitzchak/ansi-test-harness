# ansi-test-harness

ansi-test-harness is a collection of functions that aid in using
[ansi-test][] to test intrinsic and extrinsic systems that implement
parts of the Common Lisp specification. The main entry point is the
function `ansi-test-harness:ansi-test`. For example to test
[Anatomicl][] which implements the Structure dictionary:

```common-lisp
(defun test ()
  (let ((system (asdf:find-system :anatomicl-extrinsic/test)))
    (ansi-test-harness:ansi-test 
      :directory (merge-pathnames 
                   (make-pathname :directory '(:relative 
                                               "dependencies" 
                                               "ansi-test"))
                   (asdf:component-pathname system))
      :expected-failures (asdf:component-pathname 
                           (asdf:find-component system
                           '("code" "expected-failures.sexp")))
      :extrinsic-symbols '(anatomicl-extrinsic:copy-structure
                           anatomicl-extrinsic:defstruct
                           anatomicl-extrinsic:structure-class
                           anatomicl-extrinsic:structure-object)
      :tests '("STRUCT")
      :exit t)))
```

## ANSI-TEST Keyword Arguments

* `:repository` — Specifies the URL to the ansi-test repository. The
  default value is
  "https://gitlab.common-lisp.net/ansi-test/ansi-test.git"
* `:branch` — The default branch to checkout. If this is NIL then the
  repository's default branch is used.
* `:clean` — If non-NIL then an existing copy of the ansi-test
  repository will be removed before cloning.
* `:commit` — The specific commit to checkout.
* `:git` — The name of the git executable to use. The default value is
  "git".
* `:skip-sync` — If non-NIL the repository will not be cloned or
  updated. It be verified that the destination directory exists.
* `:directory` — The directory to clone ansi-test into. The default
  value is `*default-pathname-defaults*`
* `:extrinsic-symbols` — A list of symbols which will imported into
  the CL-TEST package of ansi-test thereby overridding the CL package
  version.
* `:expected-failures` — Either a list of test names or a path to a
  file containing the test names of expected failures. The latter is
  much more useful since anso-test will read that file with
  `*package*` set to CL-TEST. It will interpret unprefixed symbols as
  being the names of tests and keyword symbols as notes to
  disable. Read-time conditionals also work so items like `#+sbcl
  TEST-NAME` will add TEST-NAME to the expected failure list for SBCL
  only.
* `"tests` — A list of strings. Any test that has a name that does not
  start with one of these strings will be disabled. If `:tests` is not
  provided all tests will be run.
* `exit` — If non-NIL then ansi-test will attempt to exit the
  implmentation at the conclusion of the tests.

[ansi-test]: https://gitlab.common-lisp.net/ansi-test/ansi-test
[Anatomicl]: https://github.com/s-expressionists/Anatomicl
