% CMPUT 325 Assignment 3
% Author: Linkai Qi, 1429999
% Instructor: Demian Pimentel

% This Assignment is about problems solving in SWI Prolog.
% + and - in arguments of predicates mean input and output parameters, respectively,
% and furthermore, ? means either + or -.


% ------------------------------ #1 xreverse -----------------------------------
% xreverse(+L, ?R):
% reverse a list, where L is a given list
% and R is either a variable or another given list.
% implementation:
%   Use a helper function xreverse/3
%   add a new temperate variable 'Current' to xreverse/2
%   'Current' var is used to store partial reversed list during the execution
%   assgin the value of 'Current' to R at the base case
% test case:
%   xreverse([7,3,4],[4,3,7])    ->   true
%   xreverse([7,3,4],[4,3,5])    ->   false
%   xreverse([7,3,4], R)         ->   R = [4,3,7]

xreverse(L, R) :-
    xreverse(L, R, []).
xreverse([], R, R).
xreverse([H|T], R, Current) :-
    xreverse(T, R, [H|Current]).


% ------------------------------ #2 xunique ------------------------------------
% xunique(+L, ?O):
% Give unique item of a list, where L is a given list of atoms
% and O is a copy of L where all the duplicates have been removed.
% O can be either a variable or a given list.
% The elements of O should be in the order in which they first appear in L.
% implementation:
%   add additional variable 'Current' by creating helper function xunique/3
%   for each element in list L,
%   if L is not a member of 'Current', then add it to Current
% test case:
%   xunique([a,c,a,d], O)           ->  O = [a,c,d]
%   xunique([a,c,a,d], [a,c,d])     ->  true
%   xunique([a,c,a,d], [c,a,d])     ->  false (because of wrong order)
%   xunique([a,b,b,b,b,c,b,a], O)   ->  O = [a,b,c]
%   xunique([], O)                  ->  O = []

xunique(L, O) :- xunique(L, O, []).
xunique([], O, O).
xunique([H|T], O, Current) :-
    (member(H, Current) -> xunique(T, O, Current)
                        ; append(Current, [H], C), xunique(T, O, C)).


% -------------------------------- #3 xdiff ------------------------------------
% xdiff(+L1, +L2, -L):
% where L1 and L2 are given lists of atoms,
% and L contains the elements that are contained in L1 but not L2
% (set difference of L1 and L2).
% implementation:
%   call build-in subtract function to do set difference operation
%   and then call xunique to eliminate duplicates
% test case:
%   xdiff([a,b,f,c,d],[e,b,a,c],L)                  ->   L=[f,d]
%   xdiff([p,u,e,r,k,l,o,a,g],[n,k,e,a,b,u,t],L)    ->   L = [p,r,l,o,g]
%   xdiff([],[e,b,a,c],L)                           ->   L = []

xdiff(L1, L2, L) :-
    subtract(L1, L2, Sub),
    xunique(Sub, L).


% ----------------------------- #4 removeLast ----------------------------------
% removeLast(+L, ?L1, ?Last):
% where L is a given non-empty list, L1 is the result of removing
% the last element from L, and Last is that last element.
% L1 and Last can be either variables or given values.
% implementation:
%   while there are more than one element in the list L,
%   do cut off the head of the list L
%   return the only element in the list L
% test case:
%   removeLast([a,c,a,d], L1, Last)     ->   L1 = [a,c,a], Last = d
%   removeLast([a,c,a,d], L1, d)        ->   L1 = [a,c,a]
%   removeLast([a,c,a,d], L1, [d])      ->   false
%   removeLast([a], L1, Last)           ->   L1 = [], Last = a
%   removeLast([[a,b,c]], L1, Last)     ->   L1 = [], Last = [a,b,c]

removeLast([I], [], I).
removeLast([H|T], [H|L1], Last) :-
    removeLast(T, L1, Last) .


% ------------------------------- #5 clique ------------------------------------
% finding a subset of nodes where each node is connected to every other node
% in the subset. In this problem, a graph will be represented by a collection
% of predicates, node(A) and edge(A,B), where A and B are constants.
% Edges are undirected but only written once, so edge(A,B) also implies edge(B,A).
%node(a).
%node(b).
%node(c).
%node(d).
%node(e).

%edge(a,b).
%edge(b,c).
%edge(c,a).
%edge(d,a).
%edge(a,e).

clique(L) :- findall(X,node(X),Nodes), xsubset(L,Nodes), allConnected(L).
xappend([], L, L).
xappend([H|T], L, [H|R]) :- xappend(T, L, R).
xsubset([], _).
xsubset([X|Xs], Set) :- xappend(_, [X|Set1], Set), xsubset(Xs, Set1).

% --------------------------- #5.1 allConnected --------------------------------
% allConnected(+L):
% to test if each node in L is connected to
% each other node in L.
% testcase:
%   allConnected([a,b,c])   -> true
%   allConnected([a,b])     -> true
%   allConnected([a])       -> true
%   allConnected([])        -> true
%   allConnected([a,d])     -> false
%   allConnected([e])       -> false

allConnected([H|T]) :-
    connect(H, T), allConnected(T).
allConnected([]).

connect(_, []).
connect(A,[H|T]) :- edge(A, H), connect(A,T).
connect(A,[H|T]) :- edge(H, A), connect(A,T).


% ---------------------------- #5.2 maxclique ----------------------------------
% maxclique(N, Cliques) :-
%    findall(L,clique(L),ALL), maxclique(N, Cliques, ALL, []).
% maxclique(N, Cliques, [], Cliques).
% maxclique(N, Cliques, [H|ALL], Current) :-
%    length(H, Len), Len == N, (checkmax(H) -> 1 == 2;
%                    maxclique(N, Cliques, ALL, [H|Current])).
% checkmax(L) :- node(N), L \== N, allConnected([N|L])

% maxclique(+N, -Cliques) to compute all the maximal cliques of size N
% that are contained in a given graph. N is the given input,
% Cliques is the output you compute: a list of cliques.
% A clique is maximal if there is no larger clique that contains it.
% test case:
%   maxclique(2,Cliques) returns Cliques = [[a,d],[a,e]]
%   maxclique(3,Cliques) returns Cliques = [[a,b,c]]
%   maxclique(1,Cliques) returns Cliques = []
%   maxclique(0,Cliques) returns Cliques = []

maxclique(N, Cliques) :- findall(Clique, ismaxclique(N, Clique), Cliques).
ismaxclique(N, Clique) :-
    clique(L), length(L,Len), Len == N, findall(P,largerclique(L,P),Ps), Ps == [], Clique = L.
largerclique(L, P) :- node(N), allConnected([N|L]), P = [N|L].
