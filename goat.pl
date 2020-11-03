/* conf(Man,Wolf,Goat,Cabbage) */
initial(conf(w,w,w,w)).
final(conf(e,e,e,e)).

opposite(w,e).
opposite(e,w).

move(conf(X,X,G,C), wolf, conf(Y,Y,G,C)) :- opposite(X,Y).
move(conf(X,W,X,C), goat, conf(Y,W,Y,C)) :- opposite(X,Y).
move(conf(X,W,G,X), cabbage, conf(Y,W,G,Y)) :- opposite(X,Y).
move(conf(X,W,G,C), nothing, conf(Y,W,G,C)) :- opposite(X,Y).

together_or_separated(Same, Same, Same).
together_or_separated(_, X, Y) :- X \= Y.

safe(conf(Man,Wolf,Goat,Cabbage)) :-
    together_or_separated(Man, Wolf, Goat),
    together_or_separated(Man, Goat, Cabbage).

solution(Conf, []) :- final(Conf).
solution(Conf, [Move | Moves]) :-
    move(Conf, Move, NewConf),
    safe(NewConf),
    solution(NewConf, Moves).

solve :-
    initial(Conf),
    length(Moves, _Length),
    solution(Conf, Moves),
    writeln(Moves).
