(cl:in-package #:sicl-boot-inspector)

(clim:define-application-frame inspector ()
    ((%boot :initarg :boot :reader boot)
     (%object-stack :initarg :object-stack :accessor object-stack))
  (:panes (application
           :application
           :scroll-bars nil
           :display-function 'display-stack-top
           :text-style (clim:make-text-style :sans-serif :roman 12))
          (interactor :interactor :scroll-bars nil))
  (:layouts (default (clim:vertically (:width 1200 :height 900)
                       (4/5 (clim:scrolling () application))
                       (1/5 (clim:scrolling () interactor))))))

(defun inspect (object boot &key new-process-p)
  (let ((frame (clim:make-application-frame 'inspector
                 :object-stack (list object)
                 :boot boot)))
    (flet ((run ()
             (clim:run-frame-top-level frame)))
      (if new-process-p
          (clim-sys:make-process #'run)
          (run)))))

(define-inspector-command (com-quit :name t) ()
  (clim:frame-exit clim:*application-frame*))

                 
