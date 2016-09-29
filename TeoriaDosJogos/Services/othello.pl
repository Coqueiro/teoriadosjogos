%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Robinson Callou
% Date: 04/07/2016
%
% Othello (Reversi) modelo Jogador Vs IA com múltiplas dificuldades
% Indicação: 2-Principiante, 3-Amador, 4-intermediario, 5-Avançado, 6-Mestre
%
% setBoardSize(BoardSize). - Define tamanho do tabuleiro
% computerW. - IA joga com as brancas
% computerB. - IA joga com as pretas
% playHuman(NewBoard, Sign, Board, X, Y). - Movimento do Jogador (P=(X,Y))
% playComputer(NewBoard, Sign, Board, Level, Victory, Defeat). - Movimento da IA
%
% Tabuleiro inicial
%
%   1 2 3 4 5 6 7 8
% 1| | | | | | | | |
% 2| | | | | | | | |
% 3| | | | | | | | |
% 4| | | |W|B| | | |
% 5| | | |B|W| | | |
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
turnToSign(w, w).
turnToSign(b, b).
enemy(w, b).
enemy(b, w).
nextPlayer(w, b).
nextPlayer(b, w).

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
 (P = w ; P = b).

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
move(Board, BoardSize, Sign, ToL, ToC, NewBoard) :-
 validMove(Board, BoardSize, Sign, ToL, ToC, NewBoard).%Valida o movimento.

% Um movimento é valido se:
validMove(Board, BoardSize, Sign, NewBoard) :-
 validLoopMove(Board, BoardSize, Sign, _, _, NewBoard).%Loop de movimentos.
validMove(Board, BoardSize, Sign, ToL, ToC, NewBoard) :-
 validLoopMove(Board, BoardSize, Sign, ToL, ToC, NewBoard).%Loop de movimentos.

% Valida um movimento normal
validLoopMove(Board, BoardSize, Sign, ToL, ToC, NewBoard) :-
 findPiece(Board, BoardSize, e, ToL, ToC),
 enterLoopMove(Board, BoardSize, Sign, ToL, ToC, 8, NewBoard, 0).

enterLoopMove(Board, BoardSize, Sign, ToL, ToC, 0, NewBoard, 1) :-
 movePiece(Board, BoardSize, Sign, ToL, ToC, NewBoard), !. %RED!!!

enterLoopMove(Board, BoardSize, Sign, ToL, ToC, OffsetNum, NewBoard, Validation) :-
 directionOffset(OffsetNum, IndexL, IndexC),
 NewOffsetNum is OffsetNum -1,
 (
  validateMoveOffset(Board, BoardSize, Sign, ToL, ToC, IndexL, IndexC, TempBoard)
  ->
  NewValidation is 1,
  enterLoopMove(TempBoard, BoardSize, Sign, ToL, ToC, NewOffsetNum, NewBoard, NewValidation)
  ;
  enterLoopMove(Board, BoardSize, Sign, ToL, ToC, NewOffsetNum, NewBoard, Validation)
 ).

% Direções válidas
 directionOffset(8,  0,  1). % E
 directionOffset(7, -1,  1). % NE
 directionOffset(6, -1,  0). % N
 directionOffset(5, -1, -1). % NW
 directionOffset(4,  0, -1). % W
 directionOffset(3,  1, -1). % SW
 directionOffset(2,  1,  0). % S
 directionOffset(1,  1,  1). % SE

% Valida um único movimento normal
validateMoveOffset(Board, BoardSize, Sign, ToL, ToC, IndexL, IndexC, NewBoard) :-
 enemy(Sign, EnemySign),
 NeighborL is ToL + IndexL,
 NeighborC is ToC + IndexC,
 NeighborL >= 0, NeighborL =< BoardSize,
 NeighborC >= 0, NeighborC =< BoardSize,
 findPiece(Board, BoardSize, EnemySign, NeighborL, NeighborC),
 followOffset(Board, BoardSize, Sign, EnemySign, NeighborL, NeighborC, IndexL, IndexC, TempBoard),
 movePiece(TempBoard, BoardSize, Sign, NeighborL, NeighborC, NewBoard), !. %RED!!!

followOffset(Board, BoardSize, Sign, _, ReadL, ReadC, IndexL, IndexC, Board) :-
 EndL is ReadL + IndexL,
 EndC is ReadC + IndexC,
 EndL >= 0, EndL =< BoardSize,
 EndC >= 0, EndC =< BoardSize,
 findPiece(Board, BoardSize, Sign, EndL, EndC), !.
followOffset(Board, BoardSize, Sign, EnemySign, ReadL, ReadC, IndexL, IndexC, NewBoard) :-
 NeighborL is ReadL + IndexL,
 NeighborC is ReadC + IndexC,
 NeighborL >= 0, NeighborL =< BoardSize,
 NeighborC >= 0, NeighborC =< BoardSize,
 findPiece(Board, BoardSize, EnemySign, NeighborL, NeighborC),
 followOffset(Board, BoardSize, Sign, EnemySign, NeighborL, NeighborC, IndexL, IndexC, TempBoard),
 movePiece(TempBoard, BoardSize, Sign, NeighborL, NeighborC, NewBoard), !.

% Realiza um movimento normal
movePiece(Board, BoardSize, Sign, ToL, ToC, NewBoard) :-
 putSign(Board, BoardSize, ToL, ToC, Sign, NewBoard).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%  JOGADAS PSEUDO-ALEATÓRIAS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Realiza o movimento das peças
moveRandom(Board, BoardSize, Sign, NewBoard) :-
 moves(Sign/Board, BoardSize, PosList), !,
 random_member(_/NewBoard, PosList), !.

% Próximos movimentos
moves(Turn/Board, BoardSize, [B|Bs]) :-
 nextPlayer(Turn, NextTurn),
 findall(NextTurn/NewBoard, validMove(Board, BoardSize, Turn, NewBoard), [B|Bs]), !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%  PREDICADOS CENTRAIS DO JOGO  %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define tamanho do tabuleiro
setBoardSize(BoardSize) :-
 retractall(boardSize(_)),
 assert(boardSize(BoardSize)).

% IA joga com as brancas
computerW :-
 retractall(min2Move(_)),retractall(max2Move(_)),
 assert(min2Move(b/_)),assert(max2Move(w/_)).

% IA joga com as pretas
computerB :-
 retractall(min2Move(_)),retractall(max2Move(_)),
 assert(min2Move(w/_)),assert(max2Move(b/_)).

% Movimento do Jogador (P=(X,Y))
playHuman(NewBoard, Sign, Board, X, Y) :-
 boardSize(BoardSize),
 move(Board, BoardSize, Sign, X, Y, NewBoard),!.% Jogada

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
  victoryBoard(Board, Sign, Victory)
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
  EndGame = true, victoryBoard(Board, Sign, Victory)
 ).
 
victoryBoard(Board, Sign, Victory) :-
 enemy(Sign, EnemySign),
 (
  countElements(Board, Sign, CountS), countElements(Board, EnemySign, CountE),
  CountS >= CountE, !
  ->
  Victory = true
  ;
  Victory = false
 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%  CALCULO DA JOGADA DO COMPUTADOR  %%%%%%%%%%%%%%%%%%%%%%%%
% MiniMax + Podagem Alpha-Beta							%
% Adaptado de A. Visser, Game Playing, University of Amsterdam, 2007		%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

callMinMax(Pos, BoardSize, Alpha, Beta, GoodPos, Val, Depth, BDepth) :-
 loopAlphaBeta(Pos, BoardSize, Alpha, Beta, GoodPos, Val, Depth, BDepth), !.

loopAlphaBeta(Pos, BoardSize, Alpha, Beta, GoodPos, Val, Depth, BDepth) :-
 (
  Depth > 0,
  moves(Pos, BoardSize, PosList),!,
  bestBound(PosList, BoardSize, Alpha, Beta, GoodPos, Val, Depth, BDepth)
  ;
  turnNumber(TurnNumber),
  TurnNumber < 0.75 * BoardSize,
  staticValuation(Pos, BoardSize, Val),!			% MinMax
  ;
  staticValuation(Pos, BoardSize, SVal),			% MinMax
  dinamicValuation(Pos, BoardSize, DVal, BDepth),		% Monte Carlo
  Val is SVal * ((DVal * DVal) / BDepth)
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


% Heurística
staticValuation(Turn/Board, BoardSize, Res) :-
 boardBonus(Board, BoardSize, Turn, ResBonus),
 (
  min2Move(Turn/_),
  Res is - ResBonus
  ;
  max2Move(Turn/_),
  Res is ResBonus
 ),!.

% Bonus
boardBonus(Board, BoardSize, Sign, Bonus) :-
 countElements(Board, Sign, Count),
 positionBonus(Board, BoardSize, Sign, Position),
 Bonus is Count + Position.

% Posições no canto do tabuleiro têm maior valor
positionBonus(Board, BoardSize, Sign, Bonus) :-
 findall(Line/Col, findPiece(Board, BoardSize, Sign, Line, Col), List),!,
 positionBonusLoop(List, BoardSize, Bonus, 0).

positionBonusLoop([], _, Bonus, Bonus).
positionBonusLoop([Line/Col|Vals], BoardSize, Bonus, Res) :-
 ((Line = 1, ResL is 1, !) ; (Line = BoardSize, ResL is 1, !) ; ResL is 0),
 ((Col = 1, ResC is 1, !) ; (Col = BoardSize, ResC is 1, !) ; ResC is 0),
 NewRes is Res + ResL + ResC,
 positionBonusLoop(Vals, BoardSize, Bonus, NewRes).


% Heurística
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
