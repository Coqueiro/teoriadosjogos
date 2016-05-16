function setupOthello()
{
    window.othelloBoard = [];
    window.pieces = [];
    window.board = [];
    window.playerBlack = true;
    window.startX = 10, startY = 10, contourLength = 3, w = 40, h = 40;
    window.insideLimit = 5;
    window.blackColor = "blue";
    window.whiteColor = "yellow";
    if (typeof level == "undefined") window.level = parseInt(getParameterByName("level")) || 0;
    if (typeof lines == "undefined") window.lines = parseInt(getParameterByName("lines")) || 8;
    if (typeof rows == "undefined") window.rows = parseInt(getParameterByName("rows")) || 8;
    startMenuOthello();
}

function startMenuOthello() {
    var dimensionX = 500;
    var dimensionY = 500;
    Crafty.init(dimensionX, dimensionY, document.getElementById('gameboard'));
    renderOthelloStartMenu();
    renderOthelloSelectors();
}

function renderOthelloStartMenu() {
    Crafty.e("2D, Canvas, Color")
    .attr({ x: startX, y: startY, w: board[0] * (w + contourLength) + contourLength, h: board.length * (h + contourLength) + contourLength })
    .color("white")
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 200, y: 200 })
    .text("Othello")
    .textColor("black")
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Color, Mouse")
    .attr({ x: 200, y: 220, w: 70, h: 30 })
    .color("orange")
    .bind("MouseUp", function () { initGameOthello() })
    .bind("MouseOver", function () { this.color("red") })
    .bind("MouseOut", function () { this.color("orange") })
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 210, y: 230 })
    .text("Start game!")
    .textColor("black")
    .bind("DestroyMenu", function () { this.destroy() });
}

function renderOthelloSelectors() {
    var selectorX = 50;
    var selectorY = 50;
    var height = 35;
    var spacing = 100;

    createArraySelector("Dificuldade", "level", spacing, [0, 1, 2], 1, selectorX, selectorY);
    selectorY = selectorY + height;
    createArraySelector("Linhas", "lines", spacing, [4, 5, 6, 7, 8, 9, 10, 11, 12], 4, selectorX, selectorY);
    selectorY = selectorY + height;
    createArraySelector("Colunas", "rows", spacing, [4, 5, 6, 7, 8, 9, 10, 11, 12], 4, selectorX, selectorY);
}

function initGameOthello() {
    Crafty.trigger("DestroyMenu");
    Crafty.trigger("DestroySelector");
    othelloBoardGenerator(lines, rows);
    othelloBoardRender();
}

function othelloBoardGenerator(lines, rows) {
    while (lines > 0) {
        board.push(rows);
        lines--;
    }
}

function othelloBoardRender() {
    var y = startY + contourLength;
    var lines = 0;
    var rows;
    var othelloBoardIndex = 0;

    Crafty.e("2D, Canvas, Color")
    .attr({ x: startX, y: startY, w: board[0] * (w + contourLength) + contourLength, h: board.length * (h + contourLength) + contourLength })
    .color("black");

    while (lines <= board.length) {
        var x = startX + contourLength;
        rows = 0;
        othelloBoard.push([]);
        pieces.push([]);
        while (rows < board[lines]) {
            space = Crafty.e("2D, Canvas, Color, Mouse")
            .attr({ x: x, y: y, w: w, h: h })
            .color("white")
            .bind("Delete", function () { this.destroy() })
            .bind("Populate", function () {
                if (playerBlack) {
                    pieces[this.line][this.row].trigger("Populate", new Array(blackColor));
                    this.player = blackColor;
                }
                else {
                    pieces[this.line][this.row].trigger("Populate", new Array(whiteColor));
                    this.player = whiteColor;
                }
                this.populated = true;
            })
            .bind("PopulateByColor", function (args) {
                pieces[this.line][this.row].trigger("Populate", new Array(args[0]));
                this.player = args[0];
            })
            .bind("MouseUp", function () { spacePlacer(this.line, this.row) });

            space["line"] = lines;
            space["row"] = rows;
            space["populated"] = false;
            space["player"] = "";
            
            piece = Crafty.e("2D, Canvas, Color")
            .attr({ x: x + insideLimit, y: y + insideLimit, w: w - 2*insideLimit, h: h - 2*insideLimit })
            .color("white")
            .bind("Delete", function () { this.destroy() })
            .bind("Populate", function (args) {
                if (args[0] == "") this.color("white");
                else this.color(args[0]);
                this["player"] = args[0];
            });

            piece["player"] = "";

            pieces[lines].push(piece);

            othelloBoard[othelloBoardIndex].push(space);
            x += w + contourLength;
            rows++;
        }

        othelloBoardIndex++;
        y += h + contourLength;
        lines++;

        if (lines == board.length) {
            console.log("hi");
            pieces[Math.round(lines / 2) - 1][Math.round(rows / 2) - 1].trigger("Populate", new Array(whiteColor));
            othelloBoard[Math.round(lines / 2) - 1][Math.round(rows / 2) - 1].player = whiteColor;

            pieces[Math.round(lines / 2)][Math.round(rows / 2)].trigger("Populate", new Array(whiteColor));
            othelloBoard[Math.round(lines / 2)][Math.round(rows / 2)].player = whiteColor;

            pieces[Math.round(lines / 2) - 1][Math.round(rows / 2)].trigger("Populate", new Array(blackColor));
            othelloBoard[Math.round(lines / 2) - 1][Math.round(rows / 2)].player = blackColor;

            pieces[Math.round(lines / 2)][Math.round(rows / 2) - 1].trigger("Populate", new Array(blackColor));
            othelloBoard[Math.round(lines / 2)][Math.round(rows / 2) - 1].player = blackColor;
        }
    }
}

function spacePlacer(line, row) {
    var enemyPiece = false;
    var possiblePlay = false;
    var allyColor, enemyColor;
    if (!othelloBoard[line][row].populated) {
        if (playerBlack) {
            allyColor = blackColor;
            enemyColor = whiteColor;
        } else {
            allyColor = whiteColor;
            enemyColor = blackColor;
        }
        var iterator = 0;
        while (row + iterator < rows) {
            if (enemyPiece && pieces[line][row + iterator].player == allyColor) {
                possiblePlay = true;
                turnPieces(line, row + iterator, line, row);
            } else if (iterator == 1 && pieces[line][row + iterator].player == enemyColor) enemyPiece = true;
            iterator++;
        } 
        
        enemyPiece = false;
        iterator = 0;
        while (row + iterator < rows && line - iterator > 0) {
            if (enemyPiece && pieces[line - iterator][row + iterator].player == allyColor) {
                possiblePlay = true;
                turnPieces(line - iterator, row + iterator, line, row);
            } else if (iterator == 1 && pieces[line - iterator][row + iterator].player == enemyColor) enemyPiece = true;
            iterator++;
        }

        enemyPiece = false;
        iterator = 0;
        while (line - iterator > 0) {
            if (enemyPiece && pieces[line - iterator][row].player == allyColor) {
                possiblePlay = true;
                turnPieces(line - iterator, row, line, row);
            } else if (iterator == 1 && pieces[line - iterator][row].player == enemyColor) enemyPiece = true;
            iterator++;
        }

        enemyPiece = false;
        iterator = 0;
        while (row - iterator > 0 && line - iterator > 0) {
            if (enemyPiece && pieces[line - iterator][row - iterator].player == allyColor) {
                possiblePlay = true;
                turnPieces(line - iterator, row - iterator, line, row);
            } else if (iterator == 1 && pieces[line - iterator][row - iterator].player == enemyColor) enemyPiece = true;
            iterator++;
        }

        enemyPiece = false;
        iterator = 0;
        while (row - iterator > 0) {
            if (enemyPiece && pieces[line][row - iterator].player == allyColor) {
                possiblePlay = true;
                turnPieces(line, row - iterator, line, row);
            } else if (iterator == 1 && pieces[line][row - iterator].player == enemyColor) enemyPiece = true;
            iterator++;
        }

        enemyPiece = false;
        iterator = 0;
        while (row - iterator > 0 && line + iterator < rows) {
            if (enemyPiece && pieces[line + iterator][row - iterator].player == allyColor) {
                possiblePlay = true;
                turnPieces(line + iterator, row - iterator, line, row);
            } else if (iterator == 1 && pieces[line + iterator][row - iterator].player == enemyColor) enemyPiece = true;
            iterator++;
        }

        enemyPiece = false;
        iterator = 0;
        while (line + iterator < rows) {
            if (enemyPiece && pieces[line + iterator][row].player == allyColor) {
                possiblePlay = true;
                turnPieces(line + iterator, row, line, row);
            } else if (iterator == 1 && pieces[line + iterator][row].player == enemyColor) enemyPiece = true;
            iterator++;
        }

        enemyPiece = false;
        iterator = 0;
        while (row + iterator < rows && line + iterator < rows) {
            if (enemyPiece && pieces[line + iterator][row + iterator].player == allyColor) {
                possiblePlay = true;
                turnPieces(line + iterator, row + iterator, line, row);
            } else if (iterator == 1 && pieces[line + iterator][row + iterator].player == enemyColor) enemyPiece = true;
            iterator++;
        }
    }

    if (possiblePlay) playerBlack = !playerBlack;
}

function turnPieces(line1, row1, line2, row2) {
    while (line1 != line2 || row1 != row2) {
        othelloBoard[line1][row1].trigger("Populate");
        if (line1 != line2) line1 = nextNumber(line1, line2);
        if (row1 != row2) row1 = nextNumber(row1, row2);
    }
    othelloBoard[line2][row2].trigger("Populate");
    var options = {};
    options["level"] = level;
    queryGameboard(getOthelloBoard(), "Othello", options, setOthelloBoard);
}


function nextNumber(number1, number2) {
    if (number1 < number2) return (number1 + 1);
    else if (number1 > number2) return (number1 - 1);
    else return number1;
}

function getOthelloBoard() {
    var simpleOthelloBoard = [];
    for (var i = 0; i < othelloBoard.length - 1; i++) {
        simpleOthelloBoard.push([]);
        for (var j = 0; j < othelloBoard[i].length; j++) {
            simpleOthelloBoard[i].push(othelloBoard[i][j].player);
        }
    }
    return simpleOthelloBoard;
}

function setOthelloBoard(simpleOthelloBoard, playerTurn) {
    for (var i = 0; i < simpleOthelloBoard.length; i++) {
        for (var j = 0; j < simpleOthelloBoard[i].length; j++) {
            othelloBoard[i][j].trigger("PopulateByColor", new Array(simpleOthelloBoard[i][j]));
        }
    }
    if (playerTurn == "black") playerBlack = true;
    else if (playerTurn == "white") playerBlack = false;
}

