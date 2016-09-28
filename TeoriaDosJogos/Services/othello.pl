%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Robinson Callou
% Date: 04/07/2016
%
% Othello (Reversi) modelo Jogador Vs IA com múltiplas dificuldades
% Indicação: 2-Principiante, 3-Amador, 4-intermediario, 5-Avançado, 6-Mestre
%
% computerV. - A IA joga na vertical
% computerH. - A IA joga na horizontal
% playHuman(NewBoard, Sign, Board, X1, Y1, X2, Y2). - Movimento do Jogador
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
%%%%%%%%%%%%%%%%%%%%%%  PREDICADOS CENTRAIS DO TESTE %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Global parameter
boardSize(8).

% Initial board
initBoard(
 b(
  e,e,e,e,e,e,e,e,
  e,e,e,e,e,e,e,e,
  e,e,e,e,e,e,e,e,
  e,e,e,w,b,e,e,e,
  e,e,e,b,w,e,e,e,
  e,e,e,e,e,e,e,e,
  e,e,e,e,e,e,e,e,
  e,e,e,e,e,e,e,e
 )
).

% Notation
sign(w, 'W').% Peça
sign(b, 'B').% Peça
sign(e, ' ').% Casa vazia

% Gameplay 
:- dynamic
    min_to_move/1,
    max_to_move/1.

% AI Vs AI
play(PlayLevel1, PlayLevel2) :-
 initBoard(PlayBoard),
 callPlay1(PlayLevel1, PlayLevel2, PlayBoard).
 
callPlay1(Level1, Level2, Board) :-
 printBoard(Board),
 retractall(max2Move(_)),
 retractall(min2Move(_)),
 assertz(min2Move(w/_)),assertz(max2Move(b/_)),
 playComputer(NewBoard, w, Board, Level1, Victory, Defeat),!,
 (
  Victory = true, Defeat = false,!
  ;
  Victory = true, Defeat = false,!
  ;
  callPlay2(Level2, Level1, NewBoard)
 ).
 
callPlay2(Level1, Level2, Board) :-
 printBoard(Board),
 retractall(max2Move(_)),
 retractall(min2Move(_)),
 assertz(min2Move(b/_)),assertz(max2Move(w/_)),
 playComputer(NewBoard, b, Board, Level1, Victory, Defeat),!,
 (
  Victory = true, Defeat = false,!
  ;
  Victory = true, Defeat = false,!
  ;
  callPlay1(Level2, Level1, NewBoard)
 ).

% Imput Process
process(X1/Y1, X1, Y1).

% Prints
printBoard(Board) :-
 boardSize(BoardSize),
 write(' '),
 printHeader(BoardSize, 1),
 printBoardLines(Board, BoardSize, BoardSize, 1).

printHeader(0, _) :- nl, !.
printHeader(Loop, Num) :-
 write(' '), write(Num),
 NewLoop is Loop - 1,
 NewNum is Num + 1,
 printHeader(NewLoop, NewNum).

printBoardLines(_, _, 0, _) :- !.
printBoardLines(Board, BoardSize, Loop, Num) :-
 write(Num), printLine(Board, BoardSize, Num),
 NewLoop is Loop - 1,
 NewNum is Num + 1,
 printBoardLines(Board, BoardSize, NewLoop, NewNum).

printLine(Board, BoardSize, Num) :-
 write('|'),
 printLine(Board, BoardSize, Num, 1).

printLine(_, BoardSize, _, Loop) :- 
 Loop is BoardSize + 1,
 nl,!.
printLine(Board, BoardSize, Num, Y1) :-
 getSign(Board, BoardSize, Num, Y1, S),
 write(S),
 write('|'),
 Y2 is Y1 + 1,
 printLine(Board, BoardSize, Num, Y2).

printBoardList([]) :- !.
printBoardList([_/Board|PosList]) :-
 printBoard(Board),
 printBoardList(PosList).

% Recebe o símbolo
getSign(Board, BoardSize, Line, Col, Sign) :-
 getPos(Board, BoardSize, Line, Col, S),
 sign(S, Sign).

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

% Jogador começa
computerW :-
 assert(min2Move(b/_)),assert(max2Move(w/_)).

% Computador começa
computerB :-
 assert(min2Move(w/_)),assert(max2Move(b/_)).

% Captura o próximo movimento
playHuman(NewBoard, Sign, Board, X1, Y1, X2, Y2) :-
 boardSize(BoardSize),
 move(Board, BoardSize, Sign, X1, Y1, X2, Y2, NewBoard),!.% Jogada

% Movimento do Computador
playComputer(NewBoard, Sign, Board, Level, Victory, Defeat) :-
 boardSize(BoardSize),
 (
  validMove(Board, BoardSize, Sign, _),! 
  -> 
  Defeat = false,
  moveComputer(NewBoard, Sign, Board, Level),!,
  victoryBoard(NewBoard, Sign, Victory),!
  ; 
  Defeat = true,
  NewBoard = Board,
  Victory = false
 ),!.
 
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
 
victoryBoard(Board, Sign, Victory) :-
 boardSize(BoardSize),
 enemy(Sign, EnemySign),
 (validMove(Board, BoardSize, EnemySign, _),! -> Victory = false ; Victory = true).

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
  staticValuation(Pos, BoardSize, SVal),			% MinMax
  dinamicValuation(Pos, BoardSize, DVal, BDepth),		% Monte Carlo
  Val is SVal * (DVal/BDepth),!
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
boardBonus(Sign, Board, _, Bonus) :-
 count(Board, Sign, Res),
 Bonus is Res.

% Contador de peças
count(Board, Sign, Res) :-
 Board =.. [b|List],
 countLoop(List, Sign, Res, 0).

countLoop([], _, Res, Res) :- !.
countLoop([Sign|Vals], Sign, Res, Counter) :-
 !, Counter1 is Counter + 1,
 countLoop(Vals, Sign, Res, Counter1).
countLoop([_|Vals], Sign, Res, Counter) :-
 countLoop(Vals, Sign, Res, Counter).


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
