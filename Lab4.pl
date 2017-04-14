% CMPUT 325 Assignment 4
% Author: Linkai Qi
% Student ID: 1429999
% Instructor: Demian Pimentel

:- use_module(library(clpfd)).

/* --------------------------------------------------------------------------
Every natural number can be expressed as the sum of four or fewer squares

Given any positive integer N greater than 0,
it returns a list of non-negative integers [S1,S2,S3,S4] such that
N = S1*S1 + S2*S2 + S3*S3 + S4*S4.

fourSquares(+N, [-S1, -S2, -S3, -S4])

Test Case:
    fourSquares(1, Var).    -->     Var = [0, 0, 0, 1]
    fourSquares(6, Var).    -->     Var = [0, 1, 1, 2]
    fourSquares(20, Var).   -->     Var = [0, 0, 2, 4]; Var = [1, 1, 3, 3]
-------------------------------------------------------------------------- */
fourSquares(N, [S1, S2, S3, S4]) :-
    %Vars = [S1, S2, S3, S4],
	0#=< S1,
    S1 #=< S2,
    S2 #=< S3,
    S3 #=< S4,
	N #= S1*S1 + S2*S2 + S3*S3 + S4*S4,
	label([S1, S2, S3, S4]).


/* --------------------------------------------------------------------------
    Two countries have signed a peace treaty and want to disarm over a
period of months, but they still don't completely trust each other. Each
month one of the countries can choose to dismantle one military division
while the other can dismantle two. Each division has a certain strength,
and both sides want to make sure that the total military strength remains
equal at each point during the disarmament process.

For example, suppose the strenghs of the country's divisions are:
    > Country A: 1, 3, 3, 4, 6, 10, 12
    > Country B: 3, 4, 7, 9, 16

One solution is:
    > Month 1: A dismantles 1 and 3, B dismantles 4
    > Month 2: A dismantles 3 and 4, B dismantles 7
    > Month 3: A dismantles 12, B dismantles 3 and 9
    > Month 4: A dismantles 6 and 10, B dismantles 16

Where Adivisions and Bdivisions are lists containing the strength of each
country's divisions, and Solution is a list describing the successive
dismantlements. In the example above,
    > Solution = [[[1,3],[4]], [[3,4],[7]], [[12],[3,9]], [[6,10],[16]]]

Each element of Solution represents one dismantlement, where a dismantlement
is a list containing two elements: the first element is a list of country A's
dismantlements and the second is a list of country B's dismantlements.
Finally, the countries want to start with small dismantlements first in order
to build confidence, so make sure that the total strength of one month's
dismantlement is less than or equal to the total strength of next month's
dismantlement.

disarm(+Adivisions, +Bdivisions,-Solution)

Test Case:
    disarm([1,3,3,4,6,10,12],[3,4,7,9,16],S)
    --> S = [[[1, 3], [4]], [[3, 4], [7]], [[12], [3, 9]], [[6, 10], [16]]

    disarm([1,2,3,3,8,5,5],[3,6,4,4,10],S).
    --> S = [[[1, 2], [3]], [[3, 3], [6]], [[8], [4, 4]], [[5, 5], [10]]]

    disarm([1,2,2,3,3,8,5],[3,2,6,4,4,10],S).
    --> false

    disarm([],[],[]).
    --> true

-------------------------------------------------------------------------- */



disarm(Adivisions, Bdivisions, Solution) :-
    msort(Adivisions, Sorted_A), msort(Bdivisions, Sorted_B),
    disarm(Sorted_A, Sorted_B, Solution, [], 0).

%disarm(Adivisions, Bdivisions,Solution) :-
%    disarm(Adivisions, Bdivisions, Solution, [], 0).


disarm(Adivisions, Bdivisions, Solution, Temp, Last) :-
    % get 2 elements from Adivisions
    member(A_elem_1, Adivisions),
    select(A_elem_1, Adivisions, New_Adivisions),
    member(A_elem_2, New_Adivisions),

    % get 1 element from Bdivisions
    member(B_elem_1, Bdivisions),

    % constraint
    Last #=< B_elem_1,
    A_elem_1 + A_elem_2 #= B_elem_1,


    % remove A_elem_2 AND B_elem_1 from lists
    select(A_elem_2, New_Adivisions, New_New_Adivisions),
    select(B_elem_1, Bdivisions, New_Bdivisions),

    append(Temp, [[[A_elem_1,A_elem_2],[B_elem_1]]], New_Temp),
    disarm(New_New_Adivisions, New_Bdivisions, Solution, New_Temp, B_elem_1).


disarm(Adivisions, Bdivisions, Solution, Temp, Last) :-
    % get 2 elements from Bdivisions
    member(B_elem_1, Bdivisions),
    select(B_elem_1, Bdivisions, New_Bdivisions),
    member(B_elem_2, New_Bdivisions),

    % get 1 element from Adivisions
    member(A_elem_1, Adivisions),

    % constraint
    Last #=< A_elem_1,
    B_elem_1 + B_elem_2 #= A_elem_1,

    % remove A_elem_2 AND B_elem_1 from lists
    select(B_elem_2, New_Bdivisions, New_New_Bdivisions),
    select(A_elem_1, Adivisions, New_Adivisions),

    append(Temp, [[[A_elem_1], [B_elem_1,B_elem_2]]], New_Temp),
    disarm(New_Adivisions, New_New_Bdivisions, Solution, New_Temp, A_elem_1).

disarm([], [], Solution, Temp, _) :-
    Solution = Temp.



/* ---------------------------- old version ---------------------------------
disarm(Adivisions, Bdivisions, Solution) :-
    % get the smallest element from the two divisions
    [LA|RA] = [Adivisions],
    [LB|RB] = [Bdivisions],
    % if LA < LB, get the second smallest element from Adivisions
    LA #< LB,
    [LA2|RA2] = [RA],
    LA + LA2 #= LB,
    append(Solution, [[[LA,LA2],[LB]]], NS),
    disarm(RA2, RB, NS).

disarm(Adivisions, Bdivisions, Solution) :-
    % get the smallest element from the two divisions
    [LA|RA] = [Adivisions],
    [LB|RB] = [Bdivisions],
    % if LA < LB, get the second smallest element from Adivisions
    LA #< LB,
    [LA2|RA2] = [RA],
    LA + LA2 #= LB,
    append(Solution, [[[LA,LA2],[LB]]], NS),
    disarm(RA2, RB, NS).
-------------------------------------------------------------------------- */
