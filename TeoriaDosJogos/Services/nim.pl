%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Robinson Callou
% Date: 11/05/2016
%
% Nim modelo Jogador Vs IA com múltiplas dificuldades
% Indicação: 2-Principiante, 3-Amador, 4-intermediario, 5-Avançado, 6-Mestre
%
% setBoardSize(BoardSize). - Define tamanho do tabuleiro
% setPlayRule(PlayRule). - Define a regra de jogo (normal/misere)
% computerA. - IA joga primeiro
% computerB. - IA joga em segundo
% playHuman(NewBoard, Sign, Board, X1, Y1, X2, Y2). - Movimento do Jogador (P1=(X1,Y1) e P2=(X2,Y2), P2 esquerda de P1)
% playComputer(NewBoard, Sign, Board, Level, Victory, Defeat). - Movimento da IA
% playComputer(NewBoard, BoardSize, Sign, Board, Level, Victory, Defeat). - Movimento da IA passando tamanho do tabuleiro
%
% Tabuleiro inicial (exemplo)
%
%   1 2 3 4 5 6 
% 1|P|-|-|-|-|-|
% 2|P|P|-|-|-|-|
% 3|P|P|P|-|-|-|
% 4|P|P|P|P|-|-|
% 5|P|P|P|P|P|-|
% 6|P|P|P|P|P|P|
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%  MANIPULAÇÃO DO JOGO  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convenções
turnToSign(a, a).
turnToSign(b, b).
enemy(a, b).
enemy(b, a).
nextPlayer(a, b).
nextPlayer(b, a).

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
 P = p.

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
 movePiece(Board, BoardSize, e, ToL1, ToC1, ToL2, ToC2, NewBoard).

% Valida um único movimento normal
validateMove(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2) :-
 (Sign = a ; Sign = b),
 between(1, BoardSize, ToL1),
 between(1, ToL1, ToC1),
 findPiece(Board, BoardSize, p, ToL1, ToC1),
 EorNC is ToC1 + 1,
 (
  EorNC > BoardSize
  ;
  findPiece(Board, BoardSize, n, ToL1, EorNC)
  ;
  findPiece(Board, BoardSize, e, ToL1, EorNC)
 ),
 (
  ToL2 is ToL1,
  between(1, ToC1, ToC2)
 ),
 findPiece(Board, BoardSize, p, ToL2, ToC2).

% Realiza um movimento normal
movePiece(Board, BoardSize, Sign, ToL2, ToC2, ToL2, ToC2, NewBoard) :-
 putSign(Board, BoardSize, ToL2, ToC2, Sign, NewBoard), !.

movePiece(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 putSign(Board, BoardSize, ToL1, ToC1, Sign, TempBoard),
 NewToC1 is ToC1 - 1,
 movePiece(TempBoard, BoardSize, Sign, ToL1, NewToC1, ToL2, ToC2, NewBoard), !.

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

% Jogador começa
computerA :-
 retractall(min2Move(_)),retractall(max2Move(_)),
 assert(min2Move(b/_)),assert(max2Move(a/_)).

% Computador começa
computerB :-
 retractall(min2Move(_)),retractall(max2Move(_)),
 assert(min2Move(a/_)),assert(max2Move(b/_)).

% Captura o próximo movimento
playHuman(NewBoard, Sign, Board, X1, Y1, X2, Y2) :-
 boardSize(BoardSize),
 move(Board, BoardSize, Sign, X1, Y1, X2, Y2, NewBoard),!.% Jogada

% Movimento do Computador
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
  callMinMax(Sign/Board, BoardSize, -1000000, 1000000, _/NewBoard, _, Level, 5),!
  ->
  !
  ;
  moveRandom(Board, BoardSize, Sign, NewestBoard),
  NewBoard = NewestBoard
 ).
 
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
  staticValuation(Pos, BoardSize, SVal),			% MinMax
%  dinamicValuation(Pos, BoardSize, DVal, BDepth),		% Monte Carlo
  DVal is 5,
  ResVal is SVal * (DVal/BDepth), !,
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



% Heurística
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
boardBonus(Sign, Board, BoardSize, Bonus) :-
 moves(Sign/Board, BoardSize, PosList),!,
 length(PosList, Res),
 Bonus is Res.

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
