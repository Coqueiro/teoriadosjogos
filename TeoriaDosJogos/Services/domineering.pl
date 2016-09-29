%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Robinson Callou
% Date: 02/04/2016
%
% Domineering modelo Jogador Vs IA com múltiplas dificuldades
% Indicação: 2-Principiante, 3-Amador, 4-intermediario, 5-Avançado, 6-Mestre
%
% setBoardSize(BoardSize). - Define tamanho do tabuleiro
% setPlayRule(PlayRule). - Define a regra de jogo (normal/misere)
% computerV. - IA joga na vertical
% computerH. - IA joga na horizontal
% playHuman(NewBoard, Sign, Board, X1, Y1, X2, Y2). - Movimento do Jogador (P1=(X1,Y1) e P2=(X2,Y2), P1 superior/esquerda de P2)
% playComputer(NewBoard, Sign, Board, Level, Victory, Defeat). - Movimento da IA
% playComputer(NewBoard, BoardSize, Sign, Board, Level, Victory, Defeat). - Movimento da IA passando tamanho do tabuleiro
%
% Tabuleiro inicial (exemplo)
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
putSign(Board, BoardSize, Line, Col, Sign, NewBoard) :-
 Place is ((Line - 1) * BoardSize) + Col,
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
findPiece(Board, BoardSize, S, Line, Col) :-
 arg(Num, Board, S),
 Temp is Num / BoardSize,
 ceiling(Temp, Line),
 Col is Num - ((Line - 1) * BoardSize).

% Recebe a peça correta
getPiece(Board, BoardSize, Line, Col, P) :-
 getPos(Board, BoardSize, Line, Col, P),
 (P = v ; P = h).

% Recebe a posição
getPos(Board, BoardSize, Line, Col, Sign) :-
 Num is ((Line - 1) * BoardSize) + Col,
 arg(Num, Board, Sign).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  JOGADAS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Realiza o movimento das peças
move(Board, BoardSize, Sign, NewBoard) :-
 validMove(Board, BoardSize, Sign, NewBoard).%Valida o movimento.
move(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 validMove(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard).%Valida o movimento.

% Um movimento é valido se:
validMove(Board, BoardSize, Sign, NewBoard) :-
 validStdMove(Board, BoardSize, Sign, _, _, _, _, NewBoard).%Movimento normal.
validMove(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 validStdMove(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard).%Movimento normal.

% Valida um movimento normal
validStdMove(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 validateMove(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2),
 movePiece(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard).
 %write(L),write('/'),write(C),write('-'),write(Tl),write('/'),write(Tc),nl.

% Valida um único movimento normal
validateMove(Board, BoardSize, v, ToL1, ToC1, ToL2, ToC2) :-
 findPiece(Board, BoardSize, e, ToL1, ToC1),
 ToL2 is ToL1 + 1, 
 ToC2 is ToC1,
 findPiece(Board, BoardSize, e, ToL2, ToC2).
validateMove(Board, BoardSize, h, ToL1, ToC1, ToL2, ToC2) :-
 findPiece(Board, BoardSize, e, ToL1, ToC1),
 ToL2 is ToL1, 
 ToC2 is ToC1 + 1,
 findPiece(Board, BoardSize, e, ToL2, ToC2).

% Realiza um movimento normal
movePiece(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 putSign(Board, BoardSize, ToL1, ToC1, Sign, TempBoard),
 putSign(TempBoard, BoardSize, ToL2, ToC2, Sign, NewBoard).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%  JOGADAS PSEUDO-ALEATÓRIAS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Realiza o movimento das peças
moveRandom(Board, BoardSize, Sign, NewBoard) :-
 moves(Sign/Board, BoardSize, PosList),!,
 random_member(_/NewBoard, PosList),!.

% Próximos movimentos
moves(Turn/Board, BoardSize, [B|Bs]) :-
 nextPlayer(Turn, NextTurn),
 findall(NextTurn/NewBoard, validMove(Board, BoardSize, Turn, NewBoard), [B|Bs]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%  PREDICADOS CENTRAIS DO JOGO  %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define tamanho do tabuleiro
setBoardSize(BoardSize) :-
 retractall(boardSize(_)),
 assert(boardSize(BoardSize)).

% Define a regra de jogo
setPlayRule(PlayRule) :-
 retractall(playRule(_)),
 assert(playRule(PlayRule)).

% IA joga na vertical
computerV :-
 retractall(min2Move(_)),retractall(max2Move(_)),
 assert(min2Move(h/_)),assert(max2Move(v/_)).

% IA joga na horizontal
computerH :-
 retractall(min2Move(_)),retractall(max2Move(_)),
 assert(min2Move(v/_)),assert(max2Move(h/_)).

% Movimento do Jogador (P1=(X1,Y1) e P2=(X2,Y2), P1 superior/esquerda de P2)
playHuman(NewBoard, Sign, Board, X1, Y1, X2, Y2) :-
 boardSize(BoardSize),
 move(Board, BoardSize, Sign, X1, Y1, X2, Y2, NewBoard),!.% Jogada

% Movimento da IA
playComputer(NewBoard, Sign, Board, Level, EndGame, Victory) :-
 boardSize(BoardSize),
 (
  validMove(Board, BoardSize, Sign, _), ! 
  ->
  moveComputer(NewBoard, Sign, Board, Level), !,
  victoryBoard(NewBoard, Sign, EndGame, Victory), !
  ;
  NewBoard = Board,
  EndGame = true,
  (playRule(misere), Victory = true ; playRule(normal), Victory = false)
 ), !.

moveComputer(NewBoard, Sign, Board, Level) :-
 boardSize(BoardSize),
 (
  gameRunDown(BoardSize, Board, _),
  callMinMax(Sign/Board, BoardSize, -1000000, 1000000, _/NewBoard, _, Level, 5), !
  ->
  !
  ;
  moveRandom(Board, BoardSize, Sign, NewestBoard),
  NewBoard = NewestBoard
 ).

% Guardando turno
gameRunDown(BoardSize, Board, TurnNumber) :-
 countElements(Board, e, Empty),
 TurnNumber is ((BoardSize * BoardSize) - Empty) / BoardSize,
 retractall(turnNumber(_)),
 assert(turnNumber(TurnNumber)).

% Contador de peças
countElements(Board, Sign, Res) :-
 Board =.. [b|List],
 countLoop(List, Sign, Res, 0).

countLoop([], _, Res, Res) :- !.
countLoop([Sign|Vals], Sign, Res, Counter) :-
 !, Counter1 is Counter + 1,
 countLoop(Vals, Sign, Res, Counter1).
countLoop([_|Vals], Sign, Res, Counter) :-
 countLoop(Vals, Sign, Res, Counter).
 
victoryBoard(Board, Sign, EndGame, Victory) :-
 boardSize(BoardSize),
 enemy(Sign, EnemySign),
 (
  validMove(Board, BoardSize, EnemySign, _), !
  ->
  EndGame = false, Victory = false
  ;
  EndGame = true,
  (playRule(misere), Victory = false ; playRule(normal), Victory = true)
 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%  CALCULO DA JOGADA DO COMPUTADOR  %%%%%%%%%%%%%%%%%%%%%%
% MiniMax + Podagem Alpha-Beta
% Adaptado de A. Visser, Game Playing, University of Amsterdam, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

callMinMax(Pos, BoardSize, Alpha, Beta, GoodPos, Val, Depth, BDepth) :-
 loopAlphaBeta(Pos, BoardSize, Alpha, Beta, GoodPos, Val, Depth, BDepth), !.

loopAlphaBeta(Pos, BoardSize, Alpha, Beta, GoodPos, Val, Depth, BDepth) :-
 (
  Depth > 0,
  moves(Pos, BoardSize, PosList),!,
  bestBound(PosList, BoardSize, Alpha, Beta, GoodPos, Val, Depth, BDepth)
  ;
  turnNumber(TurnNumber),
  TurnNumber =< 0.3 * BoardSize,
  staticValuationOpen(Pos, BoardSize, ResVal), !,		% MinMax
  (playRule(misere), Val is -ResVal ; playRule(normal), Val is ResVal)
  ;
  turnNumber(TurnNumber),
  TurnNumber > 0.3 * BoardSize,
  TurnNumber =< 0.85 * BoardSize,
  staticValuation(Pos, BoardSize, ResVal), !,			% MinMax
  (playRule(misere), Val is -ResVal ; playRule(normal), Val is ResVal)
  ;
  dinamicValuation(Pos, BoardSize, ResVal, BDepth), !,		% Monte Carlo
  (playRule(misere), Val is -ResVal ; playRule(normal), Val is ResVal)
 ).								% Retorno da Posição

bestBound([Pos|PosList], BoardSize, Alpha, Beta, GoodPos, GoodVal, Depth, BDepth) :-
 NewDepth is Depth - 1,
 loopAlphaBeta(Pos, BoardSize, Alpha, Beta, _, Val, NewDepth, BDepth),
 goodEnough(PosList, BoardSize, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth, BDepth).

goodEnough([], _, _, _, Pos, Val, Pos, Val, _, _)  :-  !.	% Parada
goodEnough(_, _, Alpha, Beta, Pos, Val, Pos, Val, _, _)  :-
 (
  min2Move(Pos), Val > Beta,!					% Max atingiu limite superior
  ;
  max2Move(Pos), Val < Alpha,!					% Min atingiu limite inferior
 ).
goodEnough(PosList, BoardSize, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth, BDepth) :-
 newtBound(Alpha, Beta, Pos, Val, NewAlpha, NewBeta),		% Ajusta limites
 bestBound(PosList, BoardSize, NewAlpha, NewBeta, Pos1, Val1, Depth, BDepth),
 betterBound(Pos, Val, Pos1, Val1, GoodPos, GoodVal).

% Ajustando limites
newtBound(Alpha, Beta, Pos, Val, Val, Beta) :-
 min2Move(Pos), Val > Alpha,!.					% Max aumentou limite superior
newtBound(Alpha, Beta, Pos, Val, Alpha, Val) :-
 max2Move(Pos), Val < Beta,!.					% Min diminuiu limite inferior
newtBound(Alpha, Beta, _, _, Alpha, Beta).			% limites não mudaram

% Acha qual a melhor Posição dado seu Retorno
betterBound(Pos, Val, _, Val1, Pos, Val) :-			% Pos > Pos1
 (
  min2Move(Pos), Val > Val1,!
  ;
  max2Move(Pos), Val < Val1,!
 ).
betterBound(_, _, Pos1, Val1, Pos1, Val1).



% Heurística da abertura
staticValuationOpen(Turn/Board, BoardSize, Res) :-
 boardBonusOpen(Turn, Board, BoardSize, ResBonus),
 (
  min2Move(Turn/_),
  Res is - ResBonus
  ;
  max2Move(Turn/_),
  Res is ResBonus
 ),!.

boardBonusOpen(Turn, Board, BoardSize, Bonus) :-
 enemy(Turn, EnemyTurn),
 countBonusOpen(Turn, EnemyTurn, Board, BoardSize, Bonus, BoardSize, 0).

countBonusOpen(_, _, _, _, Bonus, 0, Bonus) :- !.
countBonusOpen(Turn, EnemyTurn, Board, BoardSize, Bonus, Loop, CounterBonus) :-
 incrementalBonusBorder(Turn, Loop, Board, BoardSize, BonusBT),
 incrementalBonusBorder(EnemyTurn, Loop, Board, BoardSize, BonusBE),
 NewCounterBonus is 
  CounterBonus 
  + 2 * BonusBT - BonusBE,
 NewLoop is Loop - 1,
 countBonusOpen(Turn, EnemyTurn, Board, BoardSize, Bonus, NewLoop, NewCounterBonus).

incrementalBonusBorder(v, Line, Board, BoardSize, Bonus) :-
 (
  findPiece(Board, BoardSize, v, Line, 2), findPiece(Board, BoardSize, e, Line, 1) 
  -> 
  BonusA is 1 ; BonusA is 0
 ),
 Aux is BoardSize - 1,
 (
  findPiece(Board, BoardSize, v, Line, Aux), findPiece(Board, BoardSize, e, Line, BoardSize) 
  -> 
  BonusB is 1 ; BonusB is 0
 ),
 Bonus is BonusA + BonusB.

incrementalBonusBorder(h, Col, Board, BoardSize, Bonus) :-
 (
  findPiece(Board, BoardSize, h, 2, Col), findPiece(Board, BoardSize, e, 1, Col) 
  -> 
  BonusA is 1 ; BonusA is 0
 ),
 Aux is BoardSize - 1,
 (
  findPiece(Board, BoardSize, h, Aux, Col), findPiece(Board, BoardSize, e, BoardSize, Col) 
  -> 
  BonusB is 1 ; BonusB is 0
 ),
 Bonus is BonusA + BonusB.



% Heurística normal
staticValuation(Turn/Board, BoardSize, Res) :-
 boardBonus(Turn, Board, BoardSize, ResBonus),
 (
  min2Move(Turn/_),
  Res is - ResBonus
  ;
  max2Move(Turn/_),
  Res is ResBonus
 ),!.

% Bonus
boardBonus(Turn, Board, BoardSize, Bonus) :-
 enemy(Turn, EnemyTurn),
 countBonus(Turn, EnemyTurn, Board, BoardSize, Bonus, BoardSize, 0).

countBonus(_, _, _, _, Bonus, 0, Bonus) :- !.
countBonus(Turn, EnemyTurn, Board, BoardSize, Bonus, Loop, CounterBonus) :-
 incrementalBonusBorder(Turn, Loop, Board, BoardSize, BonusBT),
 incrementalBonusBorder(EnemyTurn, Loop, Board, BoardSize, BonusBE),
 incrementalBonusField(Turn, Board, BoardSize, Loop, BonusFT, BoardSize, 0),
 incrementalBonusField(EnemyTurn, Board, BoardSize, Loop, BonusFE, BoardSize, 0),
 NewCounterBonus is 
  CounterBonus 
  + 2 * BonusBT - BonusBE 
  + BonusFT - BonusFE,
 NewLoop is Loop - 1,
 countBonus(Turn, EnemyTurn, Board, BoardSize, Bonus, NewLoop, NewCounterBonus).

incrementalBonusField(Sign, Board, BoardSize, _, Bonus, _, _) :-
 moves(Sign/Board, BoardSize, PosList),!,
 length(PosList, Res),
 Bonus is Res.



% Heurística do final
dinamicValuation(Turn/Board, BoardSize, Res, BDepth) :-
 playRandomLoop(Board, BoardSize, Turn, Wins, Losses, BDepth),
 (
  min2Move(Turn/_),
  Res is Losses - Wins
  ;
  max2Move(Turn/_),
  Res is Wins - Losses
 ),!.

% Contador
playRandomLoop(Board, BoardSize, Sign, Wins, Losses, Loop) :-
 countGames(Board, BoardSize, Sign, Wins, Losses, Loop, 0, 0).

countGames(_, _, _, CounterWin, CounterLoss, 0, CounterWin, CounterLoss) :- !.
countGames(Board, BoardSize, Sign, Wins, Losses, Loop, CounterWin, CounterLoss) :-
 playRandom(Board, BoardSize, Sign, Win, Loss),
 NewCounterWin is CounterWin + Win,
 NewCounterLoss is CounterLoss + Loss,
 NewLoop is Loop - 1,
 countGames(Board, BoardSize, Sign, Wins, Losses, NewLoop, NewCounterWin, NewCounterLoss).

playRandom(Board, BoardSize, Sign, Win, Loss) :-
 (
  moveRandom(Board, BoardSize, Sign, NewBoard),!
  ->
  enemy(Sign, NewSign),
  playRandom(NewBoard, BoardSize, NewSign, Loss, Win),!
  ;
  Win is 0, Loss is 1, true
 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  FIM DO PROGRAMA  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
