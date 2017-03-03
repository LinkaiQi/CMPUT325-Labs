; The FL interpreter takes a program, together with a function application,
;   and returns the result of evaluating the application.
; Parameters: P (a list of function definitions)
;             E (an expression to be evaluated)
; Test Case:
;    (fl-interp '(+ 10 5) nil) ; > '15
;    (fl-interp '(equal (3 4 1) (3 4 1)) nil) ; > 't
;    (fl-interp '(+ (* 2 2) (* 2 (- (+ 2 (+ 1 (- 7 4))) 2))) nil) ; > '12
;    (fl-interp '(or (= 5 (- 4 2)) (and (not (> 2 2)) (< 3 2))) nil) ; > 'nil
;    (fl-interp '(greater 3 5) '((greater x y = (if (> x y) x (if (< x y) y nil))))) ; > '5
;    (fl-interp '(xor t nil) '((xor x y = (if (equal x y) nil t)))) ; > 't
;    (fl-interp '(last (s u p)) '((last x = (if (null (rest x)) (first x) (last (rest x)))))) ; > 'p
;    (fl-interp '(power 4 2) '((power x y = (if (= y 1) x (power (* x x) (- y 1)))))) ; > '16
(defun fl-interp (E P)
   (cond
      ((atom E) E)   ;this includes the case where expr is nil
      (t
         (let ( (f (car E))  (arg (cdr E)) )
	          (cond
               ; handle built-in functions
               ((eq f 'if)  (if (fl-interp (car arg) P)
                 (fl-interp (cadr arg) P)
                   (fl-interp (caddr arg) P)))

               ((eq f 'null)  (null (fl-interp (car arg) P) ))
               ((eq f 'atom)  (atom (fl-interp (car arg) P) ))
               ((eq f 'eq)  (eq (fl-interp (car arg) P) (fl-interp (cadr arg) P) ))
               ((eq f 'first)  (car (fl-interp (car arg) P) ))
               ((eq f 'rest)  (cdr (fl-interp (car arg) P) ))
               ((eq f 'cons)  (cons (fl-interp (car arg) P) (fl-interp (cadr arg) P) ))
               ((eq f 'equal)  (equal (fl-interp (car arg) P) (fl-interp (cadr arg) P) ))
               ((eq f 'isnumber)  (numberp (fl-interp (car arg) P) ))


               ((eq f '+)  (+ (fl-interp (car arg) P) (fl-interp (cadr arg) P) ))
               ((eq f '-)  (- (fl-interp (car arg) P) (fl-interp (cadr arg) P) ))
               ((eq f '*)  (* (fl-interp (car arg) P) (fl-interp (cadr arg) P) ))
               ((eq f '>)  (> (fl-interp (car arg) P) (fl-interp (cadr arg) P) ))
               ((eq f '<)  (< (fl-interp (car arg) P) (fl-interp (cadr arg) P) ))
               ((eq f '=)  (= (fl-interp (car arg) P) (fl-interp (cadr arg) P) ))
               ((eq f 'and)  (and (fl-interp (car arg) P) (fl-interp (cadr arg) P) ))
               ((eq f 'or)  (or (fl-interp (car arg) P) (fl-interp (cadr arg) P) ))
               ((eq f 'not)  (not (fl-interp (car arg) P) ))


	             ; if f is a user-defined function,
               ;    then evaluate the arguments
               ;         and apply f to the evaluated arguments
               ;             (applicative order reduction)
               ((is_user_defined f P)
                  (fl-interp (map_para_args (get_para (get_P f P)) (eval_arg arg P) (get_body (get_P f P))) P)
                             ;map_para_args (para,                  args,           body)


               )

               ; otherwise f is undefined; in this case,
               ; E is returned as if it is quoted in lisp
               (t E)
            )
         )
      )
   )
)

; replaces every occurrence of X in E with V
; Parameters: X (to be replaced), V (replaced with), E (content)
; (subtitution 'x '(ab) '(xy(x))) ==> ((ab)y((ab)))
; reference: https://eclass.srv.ualberta.ca/pluginfile.php/3285800/mod_resource/content/2/mid_-_answers.pdf
(defun subtitution (X V E)
    (cond ((atom E) (if (eq E X) V E))
        (t (cons (subtitution X V (car E))(subtitution X V (cdr E))))))

; check if the function f is user-defined
; This function has two parameters: (name of the function f, Program P)
; (if user-defined, then f is in the program P)
; if user-defined, return T
; else return NIL
(defun is_user_defined (f P)
  (cond
    ((null P) nil)
    ((eq f (caar P)) t)
    (t (is_user_defined f (cdr P)))
  )
)

; apply f to the evaluated arguments
; Parameters: para (parameter of f), args (evaluated arguments of f), body (body of f)
; subtitute the bounded variable to its evaluated arguments
(defun map_para_args (para args body)
  (cond
    ((null para) body)
    (t (map_para_args (cdr para)           (cdr args) (subtitution (car para)   (car args) body)))
    ;                  X (to be replaced)  V (replaced with)                    E (in body)
  )
)

; find the corresponding function definition of f in program P
; Parameters: f (name of the function), P (program)
(defun get_P (f P)
  (cond
    ((eq f (caar P)) (car P))
    (t (get_P f (cdr P)))
  )
)

; Get the parameter list from the function definition p
; Parameters: p (function definition)
; Return: parameter list
(defun get_para (p)
  (if (eq (cadr p) '=)
    nil
    (cons (cadr p) (get_para (cdr p)))
  )
)

; Get the function's body from the function definition p
; Parameters: p (function definition)
; Return: function body
(defun get_body (p)
  (if (eq (car p) '=)
    (cadr p)
    (get_body (cdr p))
  )
)

; evaluate the arguments of the function f (AOR)
; construct the evaluated arguments to a list
; Parameters: arg (argument list), P (program)
; Return: list of evaluated arguments of function f
(defun eval_arg (arg P)
  (if (null arg)
    nil
    (cons (fl-interp (car arg) P) (eval_arg (cdr arg) P))
  )
)
