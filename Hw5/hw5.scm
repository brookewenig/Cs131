#lang racket

; This function acts like accept, and implements call/cc
(define (cont-func frag)
  (call/cc (lambda (x) 
      (cons  (lambda () (x #f)) frag)))) ; Mistake before was trying to cons frag with (x #f).

; These two functions are same as before, but replaced accept with cont-func
(define match-junk
  (lambda (k frag cont-func)
    (or (cont-func frag)
	(and (< 0 k)
	     (pair? frag)
	     (match-junk (- k 1) (cdr frag) cont-func)))))

(define match-*
  (lambda (matcher frag cont-func)
    (or (cont-func frag)
	(matcher frag
		 (lambda (frag1)
		   (and (not (eq? frag frag1))
			(match-* matcher frag1 cont-func)))))))

; Make-matcher-helper does the work that make-matcher previously did, but accepts an extra arg: cont-func
(define make-matcher-helper
  (lambda (pat)
    (cond

     ((symbol? pat)
      (lambda (frag cont-func)
	(and (pair? frag)
	     (eq? pat (car frag))
	     (cont-func (cdr frag)))))

     ((eq? 'or (car pat))
      (let make-or-matcher ((pats (cdr pat)))
	(if (null? pats)
	    (lambda (frag cont-func) #f)
	    (let ((head-matcher (make-matcher-helper (car pats)))
		  (tail-matcher (make-or-matcher (cdr pats))))
	      (lambda (frag cont-func)
		(or (head-matcher frag cont-func)
		    (tail-matcher frag cont-func)))))))

     ((eq? 'list (car pat))
      (let make-list-matcher ((pats (cdr pat)))
	(if (null? pats)
	    (lambda (frag cont-func) (cont-func frag))
	    (let ((head-matcher (make-matcher-helper (car pats)))
		  (tail-matcher (make-list-matcher (cdr pats))))
	      (lambda (frag cont-func)
		(head-matcher frag
			      (lambda (frag1)
				(tail-matcher frag1 cont-func))))))))

     ((eq? 'junk (car pat))
      (let ((k (cadr pat)))
	(lambda (frag cont-func)
	  (match-junk k frag cont-func))))

     ((eq? '* (car pat))
      (let ((matcher (make-matcher-helper (cadr pat))))
	(lambda (frag cont-func)
	  (match-* matcher frag cont-func)))))))

; Delegate the work from make make-matcher to make-matcher-helper, with one extra param: cont-func
(define (make-matcher pat)
  (lambda (frag) 
    ((make-matcher-helper pat) frag cont-func)))

; So that the test file can call these functions
(provide (all-defined-out))