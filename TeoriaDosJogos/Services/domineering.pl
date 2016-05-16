%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Robinson Callou
% Date: 02/04/2016
%
% Domineering modelo Jogador Vs IA com múltiplas dificuldades
% Indicação: 2-Principiante, 3-Amador, 4-intermediario, 5-Avançado, 6-Mestre
%
% computerV. - A IA joga na vertical
% computerH. - A IA joga na horizontal
% playHuman(NewBoard, Sign, Board, X1, Y1, X2, Y2). - Movimento do Jogador
% playComputer(NewBoard, Sign, Board, Level). - Movimento da IA
%
% Tabuleiro inicial
%
%   1 2 3 4 5 6 7 8
% 1| | | | | | | | |
% 2| | | | | | | | |
% 3| | | | | | | | |
% 4| | | | | | | | |
% 5| | | | | | | | |
% 6| | | | | | | | |
% 7| | | | | | | | |
% 8| | | | | | | | |
%
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
moveRandom(Board, Sign, NewBoard, Size) :-
 validMoveRandom(Board, Sign, NewBoard, Size).%Valida o movimento.
moveRandom(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard, Size) :-
 validMoveRandom(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard, Size).%Valida o movimento.

% Um movimento é valido se:
validMoveRandom(Board, Sign, NewBoard, Size) :-
 validStdMoveRandom(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard, Size).%Movimento normal.
validMoveRandom(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard, Size) :-
 validStdMoveRandom(Board, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard, Size).%Movimento normal.

% Valida um movimento normal, quer-se realizar somente uma jogada.
validStdMoveRandom(Board, Sign, _, _, _, _, NewBoard, Size) :-
 (
  random_between(1, Size, ToL1),
  random_between(1, Size, ToC1),
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
 assert(min2Move(h/_)),assert(max2Move(v/_)).

% Computador começa
computerH :-
 assert(min2Move(v/_)),assert(max2Move(h/_)).

% Captura o próximo movimento
playHuman(NewBoard, Sign, Board, X1, Y1, X2, Y2) :-
 move(Board, Sign, X1, Y1, X2, Y2, NewBoard),!.% Jogada

% Movimento do Computador
playComputer(NewBoard, Sign, Board, Level) :-
 validMove(Board, Sign, _),!,% Verifica se existe algum movimento válido
 (
  openningMove(NewBoard, Sign, Board, Level),!
  ;
  callMinMax(Sign/Board, -100, 100, _/NewBoard, _, Level, 10),!% Chama AI
 ),
% write(NewBoard),nl,
% moveRandom(Board, Sign, NewBoard, Size),% Random AI
 !.

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

callMinMax(Pos, Alpha, Beta, GoodPos, Val, Depth, BDepth) :-
 loopAlphaBeta(Pos, Alpha, Beta, GoodPos, Val, Depth, BDepth),
% write(Val),write(GoodPos),nl,
 !.

loopAlphaBeta(Pos, Alpha, Beta, GoodPos, Val, Depth, BDepth) :-
 (
  Depth > 0,
  moves(Pos, PosList),!,
  bestBound(PosList, Alpha, Beta, GoodPos, Val, Depth, BDepth)
  ;
  staticValuation(Pos, SVal),!,						% MinMax
  dinamicValuation(Pos, DVal, BDepth),!,				% Monte Carlo
  Val is 10*SVal + DVal,!
 ).									% Retorno da Posição

bestBound([Pos|PosList], Alpha, Beta, GoodPos, GoodVal, Depth, BDepth) :-
 NewDepth is Depth - 1,
 loopAlphaBeta(Pos, Alpha, Beta, _, Val, NewDepth, BDepth),
 goodEnough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth, BDepth).

goodEnough([], _, _, Pos, Val, Pos, Val, _, _)  :-  !.			% Parada
goodEnough(_, Alpha, Beta, Pos, Val, Pos, Val, _, _)  :-
 (
  min2Move(Pos), Val > Beta,!						% Max atingiu limite superior
  ;
  max2Move(Pos), Val < Alpha,!						% Min atingiu limite inferior
 ).
goodEnough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth, BDepth) :-	% Ajusta limites
 newtBound(Alpha, Beta, Pos, Val, NewAlpha, NewBeta),
 bestBound(PosList, NewAlpha, NewBeta, Pos1, Val1, Depth, BDepth),
 betterBound(Pos, Val, Pos1, Val1, GoodPos, GoodVal).

% Ajustando limites
newtBound(Alpha, Beta, Pos, Val, Val, Beta) :-
 min2Move(Pos), Val > Alpha,!.						% Max aumentou limite superior
newtBound(Alpha, Beta, Pos, Val, Alpha, Val) :-
 max2Move(Pos), Val < Beta,!.						% Min diminuiu limite inferior
newtBound(Alpha, Beta, _, _, Alpha, Beta).				% limites não mudaram

% Acha qual a melhor Posição dado seu Retorno
betterBound(Pos, Val, Pos1, Val1, Pos, Val) :-				% Pos > Pos1
 (
  min2Move(Pos), Val > Val1,!
  ;
  max2Move(Pos), Val < Val1,!
 ).
betterBound(_, _, Pos1, Val1, Pos1, Val1).



% Heurística
staticValuation(Turn/Board, Res) :-
 boardBonus(Turn, Board, ResBonus),
 (
  min2Move(Turn/_),
  Res is - ResBonus
  ;
  max2Move(Turn/_),
  Res is ResBonus
 ),!.

% Heurística
dinamicValuation(Turn/Board, Res, BDepth) :-
 playRandomLoop(Board, Turn, Wins, Losses, BDepth),
 (
  min2Move(Turn/_),
  Res is Losses - Wins
  ;
  max2Move(Turn/_),
  Res is Wins - Losses
 ),!.

% Contador
playRandomLoop(Board, Sign, Wins, Losses, Loop) :-
 countGames(Board, Sign, Wins, Losses, Loop, 0, 0, 8).

countGames(_, _, CounterWin, CounterLoss, 0, CounterWin, CounterLoss, _) :- !.
countGames(Board, Sign, Wins, Losses, Loop, CounterWin, CounterLoss, Size) :-
 playRandom(Board, Sign, Win, Loss, Size),
 CounterWin1 is CounterWin + Win,
 CounterLoss1 is CounterLoss + Loss,
 Loop1 is Loop - 1,
 countGames(Board, Sign, Wins, Losses, Loop1, CounterWin1, CounterLoss1, Size).

playRandom(Board, Sign, Win, Loss, Size) :-
 (
  moveRandom(Board, Sign, NewBoard, Size),!
  ->
  enemy(Sign, NewSign),
  playRandom(NewBoard, NewSign, Loss, Win, Size),!
  ;
  Win is 0, Loss is 1, true
 ).

% Bonus
boardBonus(Turn, Board, Bonus) :-
 enemy(Turn, EnemyTurn),
 countBonus(Turn, EnemyTurn, Board, Bonus, 8, 0, 8).

countBonus(_, _, _, Bonus, 0, Bonus, _) :- !.
countBonus(Turn, EnemyTurn, Board, Bonus, Loop, CounterBonus, Size) :-
 incrementalBonus(Turn, Loop, Board, BonusT, Size),
 incrementalBonus(EnemyTurn, Loop, Board, BonusE, Size),
 CounterBonus1 is CounterBonus + 2*BonusT - BonusE,
% write(BonusT),write(BonusE),write(Loop),nl,
 Loop1 is Loop - 1,
 countBonus(Turn, EnemyTurn, Board, Bonus, Loop1, CounterBonus1, Size).

incrementalBonus(v, Line, Board, Bonus, Size) :-
 (findPiece(Board, v, Line, 2), findPiece(Board, e, Line, 1) -> BonusA is 1 ; BonusA is 0),
 Aux is Size - 1,
 (findPiece(Board, v, Line, Aux), findPiece(Board, e, Line, Size) -> BonusB is 1 ; BonusB is 0),
 Bonus is BonusA + BonusB.

incrementalBonus(h, Col, Board, Bonus, Size) :-
 (findPiece(Board, h, 2, Col), findPiece(Board, e, 1, Col) -> BonusA is 1 ; BonusA is 0),
 Aux is Size - 1,
 (findPiece(Board, h, Aux, Col), findPiece(Board, e, Size, Col) -> BonusB is 1 ; BonusB is 0),
 Bonus is BonusA + BonusB.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  FIM DO PROGRAMA  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
