/**/

vaccine(File, Answer):-
	open(File, read, Stream),
	read_line(Stream, [N]),
	vaccine_loop(Stream, N, Answer),
	close(Stream).

/* The following code (input from file) is based on code found at courses.softlab.ntua.gr/pl1 */
read_line(Stream, L):-
	read_line_to_codes(Stream, Line),
	atom_codes(Atom, Line),
	atomic_list_concat(Atoms, ' ', Atom),
	maplist(atom_number, Atoms, L).
/*****/

vaccine_loop(_, 0, []):-!.
vaccine_loop(Stream, N, [A|As]):-
	read_string(Stream, "\n", "\r", _, String),
	vaccine_aux(String, A),
	N1 is N-1,
	vaccine_loop(Stream, N1, As),!.

vaccine_aux(String, A):-
	string_chars(String, L1),
	reverse(L, L1),
	length(L, Length),
	functor(S1, stack1, Length),
       	init_string(S1, 1, L),
	solve(S1, Length, A),!.

init_string(_, _, []):-!.
init_string(S, I, [H|T]):-
	setarg(I, S, H),
	I1 is I+1,
	init_string(S, I1, T),!.

init_set(0, _):-!.
init_set(L, Set):-
	setarg(L, Set, []),
	L1 is L-1,
	init_set(L1, Set).

in_set(Length, State, Set):-
	arg(Length, Set, X),
	member(State, X). 

add_to_set(Length, State, Set):-
	arg(Length, Set, X),
	setarg(Length, Set, [State|X]).

solve(S1, Length, A):-
	functor(Set, set, Length),
	init_set(Length, Set),
	arg(1, S1, S1_0),
	solution_loop(Length, S1, Set, [[['p'], false, 2, S1_0, S1_0, [S1_0] ]], [], A1),
	reverse(A1, A2),
	string_chars(A, A2),!.

complement('U', 'A').
complement('A', 'U').
complement('C', 'G').
complement('G', 'C').

solution_loop(End, Stack1, Set, [], Q, Result):-
       	reverse(Q, Q1),	
	solution_loop(End, Stack1, Set, Q1, [], Result),!.

solution_loop(End, Stack1, Set, [StateIn|Ins], Q, Vac):-
	StateIn = [Vac, Comp, Length, First, Last, Contains],
	Length > End,!. 

solution_loop(End, Stack1, Set, [StateIn|Ins], Q, Result):-
	StateIn = [Vac, Comp, Length, First, Last, Contains], 
	arg(Length, Stack1, S1_temp),
	(Comp -> complement(S1_temp, S1_0); S1_0 = S1_temp),
	in_set(Length, [S1_0, First, Last, Contains], Set),
	solution_loop(End, Stack1, Set, Ins, Q, Result),!.	

solution_loop(End, Stack1, Set, [StateIn|Ins], Q, Result):-
	StateIn = [Vac, Comp, Length, First, Last, Contains], 
	arg(Length, Stack1, S1_temp),
	(Comp -> complement(S1_temp, S1_0); S1_0 = S1_temp),
	\+in_set(Length, [S1_0, First, Last, Contains], Set),
	add_to_set(Length, [S1_0, First, Last, Contains], Set),
	
	StateC = [['c'|Vac], \+Comp, Length, First, Last, Contains],
	StateR = [['r'|Vac], Comp, Length, Last, First, Contains],

	(member(S1_0, Contains) -> Contains1 = Contains; Contains1 = [S1_0|Contains]), 
	Length1 is Length+1,
	((S1_0 = First; \+member(S1_0, Contains))->
	(StateP = [['p'|Vac], Comp, Length1, S1_0, Last, Contains1],
	solution_loop(End, Stack1, Set, Ins, [StateR, StateP, StateC|Q], Result));
	solution_loop(End, Stack1, Set, Ins, [StateR, StateC|Q], Result)),!.




