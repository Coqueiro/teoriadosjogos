%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Robinson Callou
% Date: 11/05/2016
%
% Nim2D modelo Jogador Vs IA com múltiplas dificuldades
% Indicação: 2-Principiante, 3-Amador, 4-intermediario, 5-Avançado, 6-Mestre
%
% setBoardSize(BoardSize). - Define tamanho do tabuleiro
% computerA. - IA joga primeiro
% computerB. - IA joga em segundo
% playHuman(NewBoard, Sign, Board, X1, Y1, X2, Y2). - Movimento do Jogador (P1=(X1,Y1) e P2=(X2,Y2), P1 superior/esquerda de P2)
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
 %write(L),write('/'),write(C),write('-'),write(Tl),write('/'),write(Tc),nl.

% Valida um único movimento normal
validateMove(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2) :-
 (Sign = a ; Sign = b),
 findPiece(Board, BoardSize, p, ToL1, ToC1),
 ToL1 >= ToC1,
 (
 ToL2 is ToL1 + 1, 
 ToC2 is ToC1
 ;
 ToL2 is ToL1, 
 ToC2 is ToC1 + 1
 ),
 findPiece(Board, BoardSize, p, ToL2, ToC2),
 ToL2 >= ToC2.

% Realiza um movimento normal
movePiece(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 putSign(Board, BoardSize, ToL1, ToC1, Sign, TempBoard),
 putSign(TempBoard, BoardSize, ToL2, ToC2, Sign, NewBoard).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%  JOGADAS PSEUDO-ALEATÓRIAS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Realiza o movimento das peças
moveRandom(Board, BoardSize, Sign, NewBoard) :-
 validMoveRandom(Board, BoardSize, Sign, NewBoard).%Valida o movimento.
moveRandom(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 validMoveRandom(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard).%Valida o movimento.

% Um movimento é valido se:
validMoveRandom(Board, BoardSize, Sign, NewBoard) :-
 validStdMoveRandom(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard).%Movimento normal.
validMoveRandom(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard) :-
 validStdMoveRandom(Board, BoardSize, Sign, ToL1, ToC1, ToL2, ToC2, NewBoard).%Movimento normal.

% Valida um movimento normal, quer-se realizar somente uma jogada.
validStdMoveRandom(Board, BoardSize, Sign, _, _, _, _, NewBoard) :-
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
 assert(boardSize(BoardSize)).

% Jogador começa
computerA :-
 assert(min2Move(b/_)),assert(max2Move(a/_)).

% Computador começa
computerB :-
 assert(min2Move(a/_)),assert(max2Move(b/_)).

% Captura o próximo movimento
playHuman(NewBoard, Sign, Board, X1, Y1, X2, Y2) :-
 boardSize(BoardSize),
 move(Board, BoardSize, Sign, X1, Y1, X2, Y2, NewBoard),!.% Jogada

% Movimento do Computador
playComputer(NewBoard, BoardSize, Sign, Board, Level, Victory, Defeat) :-
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
 moveRandom(Board, BoardSize, Sign, NewBoard).
 
victoryBoard(Board, Sign, Victory) :-
 boardSize(BoardSize),
 enemy(Sign, EnemySign),
 (validMove(Board, BoardSize, EnemySign, _),! -> Victory = false ; Victory = true).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  FIM DO PROGRAMA  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
