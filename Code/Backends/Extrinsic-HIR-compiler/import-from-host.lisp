(cl:in-package #:sicl-extrinsic-hir-compiler)

;;; Enter every Common Lisp special operator into the environment.
;;; We can take them from the host environment.
(loop for symbol being each external-symbol in '#:common-lisp
      when (special-operator-p symbol)
	do (setf (sicl-env:special-operator symbol *environment*) t))

;;; Define NIL and T as constant variables.
(setf (sicl-env:constant-variable t *environment*) t)
(setf (sicl-env:constant-variable nil *environment*) nil)

;;; Initially, we enter lots of functions from the host environment
;;; into the target environment.  The reason for that is so that we
;;; can run the macroexpanders of the target macros that we will
;;; define.  Later, we gradually replace these functions with target
;;; versions.
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter *imported-functions*
    '(;; From the Conses dictionary
      cons consp atom
      rplaca rplacd
      car cdr rest
      caar cadr cdar cddr
      caaar caadr cadar caddr
      cdaar cdadr cddar cddr
      caaaar caaadr caadar caaddr cadaar cadadr caddar caddr
      cdaaar cdaadr cdadar cdaddr cddaar cddadr cdddar cdddr
      first second third
      fourth fifth sixth
      seventh eighth ninth
      tenth
      copy-tree sublis nsublis
      subst subst-if subst-if-not nsubst nsubst-if nsubst-if-not
      tree-equal copy-list list list* list-length listp
      make-list nth endp null nconc
      append revappend nreconc butlast nbutlast last
      ldiff tailp nthcdr
      member member-if member-if-not
      mapc mapcar mapcan mapl maplist mapcon
      acons assoc assoc-if assoc-if-not copy-alist
      pairlis rassoc rassoc-if rassoc-if-not
      get-properties getf
      intersection nintersection adjoin
      set-difference nset-difference
      set-exclusive-or nset-exclusive-or
      subsetp union nunion
      ;; From the Sequences dictionary
      copy-seq elt fill make-sequence subseq map map-into reduce
      count count-if count-if-not
      length reverse nreverse sort stable-sort
      find find-if find-if-not
      position position-if position-if-not
      search mismatch replace
      substitute substitute-if substitute-if-not
      nsubstitute nsubstitute-if nsubstitute-if-not
      concatenate merge
      remove remove-if remove-if-not
      delete delete-if delete-if-not
      remove-duplicates delete-duplicates
      ;; From the Conditions dictionary
      error warn
      ;; From the Numbers dictionary
      = /= < > <= >= max min minusp plusp zerop
      floor ceiling truncate round
      * + - / 1+ 1- abs evenp oddp exp expt
      mod rem numberp integerp rationalp
      ;; From the Packages dictionary
      find-symbol find-package find-all-symbols
      import export intern
      packagep)))

(loop for symbol in *imported-functions*
      do (setf (sicl-env:fdefinition symbol *environment*)
	       (fdefinition symbol)))

;;; Add every environment function into the environment.
(loop for symbol being each external-symbol in '#:sicl-env
      when (fboundp symbol)
	do (setf (sicl-env:fdefinition symbol *environment*)
		 (fdefinition symbol))
      when (fboundp `(setf ,symbol))
	do (setf (sicl-env:fdefinition `(setf ,symbol) *environment*)
		 (fdefinition `(setf ,symbol))))
