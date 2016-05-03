%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Robinson Callou
% Date: 02/04/2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%  MANIPULAÇÃO DO JOGO  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convenções
turnToSign(v, v).
turnToSign(h, h).
enemy(v, h).
enemy(h, v).
nextPlayer(v, h).
nextPlayer(h, v).

% Guarda peças no tabuleiro
putSign(Board, Line, Col, Sign, NewBoard) :-
 Place is ((Line - 1) * 8) + Col,
 Board =.. [b|List],
 replace(List, Place, Sign, NewList),
 NewBoard =.. [b|NewList].

% Manipulação de partículas atómicas
replace(List, Place, Val, NewList) :-
 replace(List, Place, Val, NewList, 1).
 replace( [], _, _, [], _).
replace([_|Xs], Place, Val, [Val|Ys], Place) :-
 NewCounter is Place + 1, !,
 replace(Xs, Place, Val, Ys, NewCounter).
replace([X|Xs], Place, Val, [X|Ys], Counter) :-
 NewCounter is Counter + 1,
 replace(Xs, Place, Val, Ys, NewCounter).

% Retorna, numericamente, a posição de uma peça
findPiece(Board, S, Line, Col) :-
 arg(Num, Board, S),
 Temp is Num / 8,
 ceiling(Temp, Line),
 Col is Num - ((Line - 1) * 8).

% Recebe a peça correta
getPiece(Board, Line, Col, P) :-
 getPos(Board, Line, Col, P),
 (P = v ; P = h).

% Recebe a posição
getPos(Board, Line, Col, Sign) :-
 Num is ((Line - 1) * 8) + Col,
 arg(Num, Board, Sign).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  JOGADAS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Realiza o movimento das peças
move(Board, Sign, NewBoard) :-
 validMove(Board, Sign, NewBoard).%Valida o movimento.
move(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 validMove(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard).%Valida o movimento.

% Um movimento é valido se:
validMove(Board, Sign, NewBoard) :-
 validStdMove(Board, Sign, _, _, _, _, NewBoard).%Movimento normal.
validMove(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 validStdMove(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard).%Movimento normal.

% Valida um movimento normal
validStdMove(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 validateMove(Board, Sign, ToL1, ToC1, ToL2, ToC2),
 movePiece(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard).
 %write(L),write('/'),write(C),write('-'),write(Tl),write('/'),write(Tc),nl.

% Valida um único movimento normal
validateMove(Board, v, ToL1, ToC1, ToL2, ToC2) :-
 findPiece(Board, e, ToL1, ToC1),
 ToL2 is ToL1 + 1, 
 ToC2 is ToC1,
 findPiece(Board, e, ToL2, ToC2).
validateMove(Board, h, ToL1, ToC1, ToL2, ToC2) :-
 findPiece(Board, e, ToL1, ToC1),
 ToL2 is ToL1, 
 ToC2 is ToC1 + 1,
 findPiece(Board, e, ToL2, ToC2).

% Realiza um movimento normal
movePiece(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 putSign(Board, ToL1, ToC1, Sign, TempBoard),
 putSign(TempBoard, ToL2, ToC2, Sign, NewBoard).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%  JOGADAS PSEUDO-ALEATÓRIAS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Realiza o movimento das peças
moveRandom(Board, Sign, NewBoard) :-
 validMoveRandom(Board, Sign, NewBoard).%Valida o movimento.
moveRandom(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 validMoveRandom(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard).%Valida o movimento.

% Um movimento é valido se:
validMoveRandom(Board, Sign, NewBoard) :-
 validStdMoveRandom(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard).%Movimento normal.
validMoveRandom(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 validStdMoveRandom(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard).%Movimento normal.

% Valida um movimento normal, quer-se realizar somente uma jogada.
validStdMoveRandom(Board, Sign, _, _, _, _, NewBoard) :-
 (
  random_between(1, 8, ToL1),
  random_between(1, 8, ToC1),
  findPiece(Board, e, ToL1, ToC1),!,
  (
   Sign = v,!,
   ToL2 is ToL1 + 1,!,
   ToC2 is ToC1,!
   ;
   Sign = h,!,
   ToL2 is ToL1,!,
   ToC2 is ToC1 + 1,!
  ),
  findPiece(Board, e, ToL2, ToC2),!,
  movePiece(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard),!
  ;
  moves(Sign/Board, PosList),!,
  random_member(_/NewBoard, PosList),!
 ).

% Próximos movimentos
moves(Turn/Board, [B|Bs]) :-
 nextPlayer(Turn, NextTurn),
 findall(NextTurn/NewBoard, validMove(Board, Turn, NewBoard), [B|Bs]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%-%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%  PREDICADOS CENTRAIS DO JOGO  %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Jogador começa
computerV :-
 assert(min_to_move(h/_)),assert(max_to_move(v/_)).

% Computador começa
computerH :-
 assert(min_to_move(v/_)),assert(max_to_move(h/_)).

% Captura o próximo movimento
playHuman(NewBoard, Sign, Board, X1, Y1, X2, Y2) :-
 move(Board, Sign, X1, Y1, X2, Y2, NewBoard),!.% Jogada

% Movimento do Computador
playComputer(NewBoard, Sign, Board, Level) :-
 validMove(Board, Sign, _),!,% Verifica se existe algum movimento válido
 (
  openningMove(NewBoard, Sign, Board, Level),!
  ;
  alphabeta(Sign/Board, 0, 0, _/NewBoard, _, Level),!% Chama AI
 ).
% moveRandom(Board, Sign, NewBoard),!.% Random AI

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%  CALCULO DA JOGADA DO COMPUTADOR  %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Jogada de Abertura
openningMove(NewBoard, Sign, Board, Level) :-
 false,!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MiniMax + Podagem Alpha-Beta
% Adaptado de A. Visser, Game Playing, University of Amsterdam, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

alphabeta(Pos, Alpha, Beta, GoodPos, Val, Depth) :-
 (
  Depth > 0,!,
  moves(Pos, PosList),!,
  boundedbest(PosList, Alpha, Beta, GoodPos, Val, Depth)
  ;
  staticval(Pos, Val),!
 ).							% Retorno da Posição

boundedbest([Pos|PosList], Alpha, Beta, GoodPos, GoodVal, Depth) :-
 NewDepth is Depth - 1,
 alphabeta(Pos, Alpha, Beta, _, Val, NewDepth),
 goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth).

goodenough([], _, _, Pos, Val, Pos, Val, _)  :-  !.			% Parada
goodenough(_, Alpha, Beta, Pos, Val, Pos, Val, _)  :-
 (
  min_to_move(Pos), Val > Beta,!					% Max atingiu limite superior
  ;
  max_to_move(Pos), Val < Alpha,!					% Min atingiu limite inferior
 ).
goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth) :-	% Ajusta limites
 newbounds(Alpha, Beta, Pos, Val, NewAlpha, NewBeta),
 boundedbest(PosList, NewAlpha, NewBeta, Pos1, Val1, Depth),
 betterof(Pos, Val, Pos1, Val1, GoodPos, GoodVal).

% Ajustando limites
newbounds(Alpha, Beta, Pos, Val, Val, Beta) :-
 min_to_move(Pos), Val > Alpha,!.					% Max aumentou limite superior
newbounds(Alpha, Beta, Pos, Val, Alpha, Val) :-
 max_to_move(Pos), Val < Beta,!.					% Min diminuiu limite inferior
newbounds(Alpha, Beta, _, _, Alpha, Beta).				% limites não mudaram

% Acha qual a melhor Posição dado seu Retorno
betterof(Pos, Val, Pos1, Val1, Pos, Val) :-				% Pos > Pos1
 (
  min_to_move(Pos), Val > Val1,!
  ;
  max_to_move(Pos), Val < Val1,!
 ).
betterof(_, _, Pos1, Val1, Pos1, Val1).

% Heurística
staticval(Turn/Board, Res) :-
 playRandomLoop(Board, Turn, Wins, Losses, 10),
% random_between(1, 10, Wins),random_between(1, 10, Losses),
 (
  min_to_move(Turn/_),
  ResCount is Losses/2 - Wins/2,!
  ;
  max_to_move(Turn/_),
  ResCount is Wins/2 - Losses/2,!
 ),
 boardBonus(Board, Turn, ResBonus),
 Res is ResCount + ResBonus,
% !,printBoard(Board),
% write(Res),nl,
 !.

% Contador
playRandomLoop(Board, Sign, Wins, Losses, Loop) :-
 countGames(Board, Sign, Wins, Losses, Loop, 0,0).

countGames(_, _, CounterWin, CounterLoss, 0, CounterWin, CounterLoss) :- !.
countGames(Board, Sign, Wins, Losses, Loop, CounterWin, CounterLoss) :-
 playRandom(Board, Sign, Win, Loss),
 CounterWin1 is CounterWin + Win,
 CounterLoss1 is CounterLoss + Loss,
 Loop1 is Loop - 1,
 countGames(Board, Sign, Wins, Losses, Loop1, CounterWin1, CounterLoss1).

playRandom(Board, Sign, Win, Loss) :-
 (
  moveRandom(Board, Sign, NewBoard),!
  ->
  enemy(Sign, NewSign),playRandom(NewBoard, NewSign, Loss, Win),!
  ;
  Win is 0,Loss is 1,true
 ).

% Bonus
boardBonus(_, _, ResBonus) :-
 ResBonus is 0.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  FIM DO PROGRAMA  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%