#| QUESTION 1.
The function xmember takes two arguments, The first argument A should be a list,
otherwise it returns NIL. The function checks if the the second argument B is
in list A. If yes, return T. If not, return NIL.

test case:
  (xmember '(1) '1)               => T
  (xmember '((1) 2 3) '1)         => NIL
  (xmember '((1) 2 3) '(1))       => T
  (xmember nil nil)               => NIL
  (xmember '(nil) nil)            => T
  (xmember '((nil)) nil)          => NIL
  (xmember '(1 2 3 (nil)) '(nil)) => T
  (xmember '(nil) '(nil))         => NIL
|#

(defun xmember (X Y)
    (if (NULL X)
        NIL
        (if (equal(car X) Y)
            'T
            (xmember (cdr X) Y))))





#| QUESTION 2.
This function takes one list x, and returns a single list of atoms which remain
the same order as they appear in list x. The list x may has sublists in it. so,
basically the function is to remove all parentheses in x.
test case:
  (flatten '(a (b c) d))           => (a b c d)
  (flatten '((((a)))))             => (a)
  (flatten '(a (b c) (d ((e)) f))) => (a b c d e f)
|#

(defun flatten (x)
    (if (NULL x)
	NIL
	(if (atom (car x))
            (append (cons (car x) ()) (flatten (cdr x)))
            (append (flatten (car x)) (flatten(cdr x)))
	)
    )
)





#| QUESTION 3.
The function takes two lists as its arguments, and return a list that contains
the mix of the two lists. The way the function mixes the two list is by choosing
elements from L1 and L2 alternatingly. If one of the list run out of element,
then append all elements from the longer list at the end of the output list at
once.
test case:
  (mix '(d e f) '(a b c)) => (a d b e c f)
  (mix '(a) '(1 2 3))     => (1 a 2 3)
  (mix '(d e f g h) '((a) (b c))) => ((a) d (b c) e f g h)
  (mix nil '(1 2 3)) => (1 2 3)
  (mix '(nil) '(1 2 3)) => (1 nil 2 3)
|#

(defun mix (L2 L1)
    (cond ((NULL L2) L1)
          ((NULL L1) L2)
          ((append(cons (car L1) (cons (car L2) ()))
                  (mix (cdr L2) (cdr L1))))))





#| QUESTION 4.
The function split the elements of L into a list of two sublist(L1 L2), by
putting elements from L into L1 and L2 alternatingly, until there is no element
left in the list L. The splitting start at L1. The function uses a helper
function (xsplit) to solve the problem.
Call xsplit with 3 arguments (L L1 L2). L is the original input list.
L1, L2 are the sublists. Initialize L1, L2.
test case:
  (split '(1 2 3 4 5 6)) => ((1 3 5) (2 4 6))
  (split '((a) (b c) (d e f) g h)) => (((a) (d e f) h) ((b c) g))
  (split '()) => (nil nil)
|#

(defun split (L)
    (xsplit L () ()))


#|
The helper function takes (L, L1, L3). By calling (cddr L), each recursion it
moves forward to the next 2 element of list L. In each recursion, the helper
function saves the first element to the sublist L1, and append the second
element to the sublist L2. Basic case: there is no element in the list L,
return L1, L2.
|#

(defun xsplit (L L1 L2)
    (if (not(null (car L)))
        (if (not(null (cdr L)))
            (xsplit (cddr L) (append L1 (cons(car L)())) (append L2 (cons(cadr L) ())))
            (xsplit (cddr L) (append L1 (cons(car L)())) L2))
    (cons L1 (cons L2 () ) )        ))





#| QUESTION 5.
5.1 Let L1 and L2 be lists. Is it always true that (split (mix L2 L1)) returns
the list (L1 L2)? If yes, give a proof. If no, describe exactly for which pairs
of lists L1, L2 the result is different from (L1 L2).
No, it is not always true. When the length of L2 > the length of L1,
it does not hold.
For example (split (mix '(A B C) '(D E))) => ((D E C) (A B))

5.2 Let L be a list. Is it always true that (mix (cadr (split L)) (car (split L)))
returns L? If yes, give a proof. If no, describe exactly for which lists L the
result is different from L.
Yes, it is always true. When we call function split, we first place the element
at the left-hand-side sublist, and then right-hand-side sublist. But the
function mix will first get the first element of the right-hand-side sublist,
and then the left-hand-side sublist. By switching the order of sublist (using cadr, car),
the order of element recombination is exactly as same as the order of element
decomposition. Therefore, it is always true that (mix (cadr (split L)) (car (split L)))
will returns L
|#





#| QUESTION 6.
Subsetsum: Given a list of numbers L and a sum S, find a subset of the numbers
in L that sums up to S. Each number in L can only be used once.
The function subsetsum takes two parameters. The first one is the sum S,
the second one is the input list L that needs to select element from.
If we can find a subset of elements in list L that sum of the subset is equal
to S, then return the subset, otherwise return NIL.
The algorithm I use in this question is try all different combinations of
elements selection, and test them if they can sum up to S.
Base Case: 1. No element left in the list (nil)
           2. There is a element in the list which value equals to S (find solution)
           3. S is less than 0 (since there is no negative element, if the value of S
                                decrease to below zero, return nil.)
Pseudo code:
    function subsetsum (sum, list)
         if (list == null)            # Base case
             return nil
         else if (sum < 0)            # Base case
             return nil
         else if (list[1] == sum)     # Base case
             return list[1]
         else:
             if (subsetsum (sum - list[1], list[2:]) == nil)
                 subsetsum (sum, list[2:])
             else:
                 list[1] + subsetsum (sum - list[1], list[2:])
Test Case:
  (subsetsum 5 '(1 2 3))               => (2 3)
  (subsetsum 2 '(1 5 3))               => nil
  (subsetsum 29 '(1 16 2 8 4))         => (1 16 8 4)
  (subsetsum 10 '(1 1 5 6 8))          => (1 1 8)
  (subsetsum 5 '(1 10 100 1000 10000)) => nil
|#

(defun subsetsum (S L)
    (if (null (car L))
        nil
        (if (< S 0)
            nil
            (if (= S (car L))
                (cons (car L) ())
                (if (null (subsetsum  S  (cdr L)))
		                    (if (null (subsetsum  (- S (car L))  (cdr L)))
                        nil
                        (cons (car L)   (subsetsum  (- S (car L))  (cdr L))))
                    (subsetsum  S  (cdr L)) )))))
