/**/
count_and_remove(N, [N|T], L,  S):-
	 count_and_remove(N, T, L, S1),
	 S is S1+1,!.
count_and_remove(_, T, T, 0):-!.

form([], _, []):-!.
form(L, N, F):-
	F = [S|T],
	N1 is N+1,
	count_and_remove(N, L, L1, S),
	form(L1, N1, T),!.

binary(0, [], _):-!.
binary(N, [A|B], A):-
	1 is N mod 2,
	N1 is N//2,
	A1 is A+1,
	binary(N1, B, A1),!.
binary(N, B, A):-
	0 is N mod 2,
	N1 is N//2,
	A1 is A+1,
	binary(N1, B, A1),!.

expand(P, 0, P):-!.
expand([0|T], K, [0|P]):-
	expand(T, K, P),!.
expand([H|T], K, P):-
	H1 is H-1,
	K1 is K-1,
	expand([H1, H1|T], K1, P),!.

powers2_aux(N, K, P):-
	binary(N, Binary, 0),
	length(Binary, L),
	((K =< N, K >= L) -> (K1 is K-L, expand(Binary, K1, P1), form(P1, 0, P)); P = []),!.

loop(0, _, []):-!.
loop(I, [[N, K]| T], [P|Ps]) :-
	powers2_aux(N, K, P),
        I1 is I-1,
	loop(I1, T, Ps),!.	

powers2(File, Answers):-
	open(File, read, Stream),
    	read_line(Stream, [T]),
    	read_input(Stream, L),
	loop(T, L, Answers),
	close(Stream).

/* The following code is based on code found at courses.softlab.ntua.gr/pl1*/
read_input(Stream, []) :-
    at_end_of_stream(Stream),!.
read_input(Stream, [H|T]) :-
    read_line(Stream, H),
    read_input(Stream, T),!.

read_line(Stream, L) :-
    read_line_to_codes(Stream, Line),
    atom_codes(Atom, Line),
    atomic_list_concat(Atoms, ' ', Atom),
    maplist(atom_number, Atoms, L).
