/**/

/* The reading form file code is based on code found at courses.softlab.ntua.gr/pl1 */ 

read_lines(0, _, []):-!. 
read_lines(_, Stream, []):-
	at_end_of_stream(Stream),!.
read_lines(N, Stream, [H|T]):-
	read_line(Stream, H),
	N1 is N-1,
	read_lines(N1, Stream, T),!.

read_line(Stream, L):-
	read_line_to_codes(Stream, Line),
	atom_codes(Atom, Line),
	atomic_list_concat(Atoms, ' ', Atom),
	maplist(atom_number, Atoms, L).

/******/

delete(N, [N|T], T):-!.
delete(N, [H|T], [H|L]):-
	delete(N, T, L).

delete_edge(U, V, G):-
	arg(U, G, L1),
        delete(V, L1, L1n),
	setarg(U, G, L1n),
	arg(V, G, L2),
        delete(U, L2, L2n),
	setarg(V, G, L2n).
		

init_graph(0, _):-!.
init_graph(V, G):-
	arg(V, G, []),
	V1 is V-1,
	init_graph(V1, G),!.

init_parent(0, _):-!.
init_parent(V, P):-
	setarg(V, P, -1),
	V1 is V-1,
	init_parent(V1, P),!.

init_cycle(C):-
	arg(1, C, -1),
	arg(2, C, -1).

create_graph(_, [], _):-!.
create_graph(V, [[X,Y]|L], G):-
	arg(X, G, A1),
	arg(Y, G, A2),
	setarg(X, G, [Y|A1]),
	setarg(Y, G, [X|A2]),
	create_graph(V, L, G),!.

dfs(Current, G, P, C, Num):-
	arg(Current, G, L),
	dfs_aux(Current, L, G, P, C, Num),!.

dfs_aux(_, [], _, _, _, 1):-!.
dfs_aux(Current, [H|T], G, P, C, Num):-
	(arg(H, P, -1) -> (setarg(H, P, Current), 
			   dfs(H, G, P, C, Num1),
			   dfs_aux(Current, T, G, P, C, Num2),
			   Num is Num1 + Num2);
			   ((arg(1, C, -1), \+arg(Current, P, H)) -> 
				   (setarg(H, P, Current),
				    setarg(1, C, H),
				    setarg(2, C, Current),
				    dfs_aux(Current, T, G, P, C, Num));
				    dfs_aux(Current, T, G, P, C, Num))),!.

get_cycle(Current, G, _, C, [Current]):-
	arg(1, C, Current),
	arg(2, C, Prev),
	delete_edge(Current, Prev, G),!. 
get_cycle(Current, G, P, C, [Current|T]):-
	arg(Current, P, Prev),
	delete_edge(Current, Prev, G),
	get_cycle(Prev, G, P, C, T),!.


treeSize_aux(_, _, [], _, _, 1):-!.
treeSize_aux(Current, Parent, [H|T], G, P, Num):-
	(H \= Parent -> (treeSize(H, Current, G, P, Num1), 
		         treeSize_aux(Current, Parent, T, G, P, Num2),
		         Num is Num1 + Num2);
			 treeSize_aux(Current, Parent, T, G, P, Num)),!.


treeSize(Current, Parent, G, P, Num):-
	arg(Current, G, L),
	treeSize_aux(Current, Parent, L, G, P, Num),!.

treeSizes([], _, _, []):-!.
treeSizes([H|T], G, P, [S|Ss]):-
	treeSize(H, H, G, P, S),
	treeSizes(T, G, P, Ss),!.

coronograph_aux(V, E, _, "'NO CORONA'"):- V \= E,!.
coronograph_aux(V, V, L, A):-
	functor(G, graph, V),
	functor(P, parent, V),
	functor(C, cycle, 2),
	init_graph(V, G),
	init_parent(V, P),
	init_cycle(C),
	create_graph(V, L, G),
	dfs(1, G, P, C, Num),
	(V is Num-1  -> (arg(2, C, Last), 
			get_cycle(Last, G, P, C, Cycle),
			length(Cycle, Length),
			/*init_parent(V, P),*/
			treeSizes(Cycle, G, P, Sizes),
			msort(Sizes, SortedS),
			A = [Length, SortedS]); A = "'NO CORONA'"),!.

loop(0, _, []):-!.
loop(I, Stream, [A|As]):-
	read_line(Stream, [V, E]),
	read_lines(E, Stream, L),
	coronograph_aux(V, E, L, A),
	I1 is I-1,
	loop(I1, Stream, As),!.

coronograph(File, Answers):-
	open(File, read, Stream),
	read_line(Stream, [T]),
	loop(T, Stream, Answers),
	close(Stream).

