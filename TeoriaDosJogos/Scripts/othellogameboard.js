function setupOthello()
{
    window.othelloBoard = [];
    window.pieces = [];
    window.board = [];
    window.playerBlack = true;
    window.startX = 10, startY = 10, contourLength = 3, w = 40, h = 40;
    window.freeze = false;
    window.insideLimit = 5;
    window.blackColor = "blue";
    window.whiteColor = "yellow";
    window.level = parseInt(getParameterByName("level")) || 1;
    window.lines = parseInt(getParameterByName("lines")) || 8;
    window.rows = parseInt(getParameterByName("rows")) || 8;
    window.firstPlayer = getParameterByName("firstPlayer") || "Black";
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

function renderOthelloGameOver(message) {
    Crafty.e("2D, Canvas, Color")
    .attr({ x: startX, y: startY, w: board[0] * (w + contourLength) + contourLength, h: board.length * (h + contourLength) + contourLength })
    .color("white", 0.7)
    .bind("DestroyGameOver", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 200, y: 200 })
    .text(message)
    .textColor("black")
    .bind("DestroyGameOver", function () { this.destroy() });

    Crafty.e("2D, Canvas, Color, Mouse")
    .attr({ x: 200, y: 220, w: 70, h: 30 })
    .color("orange")
    .bind("MouseUp", function () {
        setupOthello();
        Crafty.trigger("DestroyGameOver");
        Crafty.trigger("Terminate");
    })
    .bind("MouseOver", function () { this.color("red") })
    .bind("MouseOut", function () { this.color("orange") })
    .bind("DestroyGameOver", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 210, y: 230 })
    .text("Go to Menu!")
    .textColor("black")
    .bind("DestroyGameOver", function () { this.destroy() });
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
    selectorY = selectorY + height;
    createArraySelector("Primeiro player", "firstPlayer", spacing, ["Black", "White"], 0, selectorX, selectorY);
}

function initGameOthello() {
    Crafty.trigger("DestroyMenu");
    Crafty.trigger("DestroySelector");
    othelloBoardGenerator(lines, rows);
    othelloBoardRender();
    if (firstPlayer == "White") {
        freeze = true;
        var options = {};
        options["level"] = level;
        if (playerBlack) options["orientation"] = "w";
        else if (!playerBlack) options["orientation"] = "b";
        queryGameboard(getOthelloBoard(), "Othello", options, setOthelloBoard);
    };
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
    .color("black")
    .bind("Terminate", function() {this.destroy() });

    while (lines <= board.length) {
        var x = startX + contourLength;
        rows = 0;
        othelloBoard.push([]);
        pieces.push([]);
        while (rows < board[lines]) {
            space = Crafty.e("2D, Canvas, Color, Mouse")
            .attr({ x: x, y: y, w: w, h: h })
            .color("white")
            .bind("Terminate", function () { this.destroy() })
            .bind("Delete", function () { this.destroy() })
            .bind("Populate", function () {
                if (playerBlack) {
                    pieces[this.line][this.row].trigger("Populate", new Array(blackColor, "b"));
                    this.player = blackColor;
                    this.playerDirection = "b";
                }
                else {
                    pieces[this.line][this.row].trigger("Populate", new Array(whiteColor, "w"));
                    this.player = whiteColor;
                    this.playerDirection = "w";
                }
                this.populated = true;
            })
            .bind("PopulateByColor", function (args) {
                this.player = "";
                var direction = args[0];
                if (args[0] == "b") this.player = blackColor;
                else if (args[0] == "w") this.player = whiteColor;
                this.playerDirection = direction;
                pieces[this.line][this.row].trigger("Populate", new Array(this.player, direction));
            })
            .bind("MouseUp", function () { if (!freeze) spacePlacer(this.line, this.row, "") })
            .bind("Coloring", function (args) {
                pieces[this.line][this.row].trigger("Coloring", args);
            })
            .bind("MouseOver", function (){
                if (!freeze) spacePlacer(this.line, this.row, "red");
            })
            .bind("MouseOut", function () {
                if (!freeze) spacePlacer(this.line, this.row, "white");
            });

            space["line"] = lines;
            space["row"] = rows;
            space["populated"] = false;
            space["player"] = "";
            space["playerDirection"] = "e";
            
            piece = Crafty.e("2D, Canvas, Color")
            .attr({ x: x + insideLimit, y: y + insideLimit, w: w - 2*insideLimit, h: h - 2*insideLimit })
            .color("white")
            .bind("Terminate", function () { this.destroy() })
            .bind("Delete", function () { this.destroy() })
            .bind("Populate", function (args) {
                if (args[0] == "") this.color("white");
                else {
                    this.color(args[0]);
                    this["player"] = args[0];
                    this["playerDirection"] = args[1];
                    this["populated"] = true;
                }
            })
            .bind("Coloring", function (args) {
                if(!this.populated) this.color(args[0]);
            });

            piece["player"] = "";
            piece["playerDirection"] = "e";
            piece["populated"] = false;

            pieces[lines].push(piece);

            othelloBoard[othelloBoardIndex].push(space);
            x += w + contourLength;
            rows++;
        }

        othelloBoardIndex++;
        y += h + contourLength;
        lines++;

        if (lines == board.length) {
            pieces[Math.round(lines / 2) - 1][Math.round(rows / 2) - 1].trigger("Populate", new Array(whiteColor, "w"));
            othelloBoard[Math.round(lines / 2) - 1][Math.round(rows / 2) - 1].player = whiteColor;
            othelloBoard[Math.round(lines / 2) - 1][Math.round(rows / 2) - 1].playerDirection = "w";

            pieces[Math.round(lines / 2)][Math.round(rows / 2)].trigger("Populate", new Array(whiteColor, "w"));
            othelloBoard[Math.round(lines / 2)][Math.round(rows / 2)].player = whiteColor;
            othelloBoard[Math.round(lines / 2)][Math.round(rows / 2)].playerDirection = "w";

            pieces[Math.round(lines / 2) - 1][Math.round(rows / 2)].trigger("Populate", new Array(blackColor, "b"));
            othelloBoard[Math.round(lines / 2) - 1][Math.round(rows / 2)].player = blackColor;
            othelloBoard[Math.round(lines / 2) - 1][Math.round(rows / 2)].playerDirection = "b";

            pieces[Math.round(lines / 2)][Math.round(rows / 2) - 1].trigger("Populate", new Array(blackColor, "b"));
            othelloBoard[Math.round(lines / 2)][Math.round(rows / 2) - 1].player = blackColor;
            othelloBoard[Math.round(lines / 2)][Math.round(rows / 2) - 1].playerDirection = "b";
        }
    }
}

function spacePlacer(line, row, color) {
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
                if(color == "") turnPieces(line, row + iterator, line, row);
            } else if (iterator == 1 && pieces[line][row + iterator].player == enemyColor) enemyPiece = true;
            iterator++;
        } 
        
        enemyPiece = false;
        iterator = 0;
        while (row + iterator < rows && line - iterator > 0) {
            if (enemyPiece && pieces[line - iterator][row + iterator].player == allyColor) {
                possiblePlay = true;
                if (color == "") turnPieces(line - iterator, row + iterator, line, row);
            } else if (iterator == 1 && pieces[line - iterator][row + iterator].player == enemyColor) enemyPiece = true;
            iterator++;
        }

        enemyPiece = false;
        iterator = 0;
        while (line - iterator > 0) {
            if (enemyPiece && pieces[line - iterator][row].player == allyColor) {
                possiblePlay = true;
                if (color == "") turnPieces(line - iterator, row, line, row);
            } else if (iterator == 1 && pieces[line - iterator][row].player == enemyColor) enemyPiece = true;
            iterator++;
        }

        enemyPiece = false;
        iterator = 0;
        while (row - iterator > 0 && line - iterator > 0) {
            if (enemyPiece && pieces[line - iterator][row - iterator].player == allyColor) {
                possiblePlay = true;
                if (color == "") turnPieces(line - iterator, row - iterator, line, row);
            } else if (iterator == 1 && pieces[line - iterator][row - iterator].player == enemyColor) enemyPiece = true;
            iterator++;
        }

        enemyPiece = false;
        iterator = 0;
        while (row - iterator > 0) {
            if (enemyPiece && pieces[line][row - iterator].player == allyColor) {
                possiblePlay = true;
                if (color == "") turnPieces(line, row - iterator, line, row);
            } else if (iterator == 1 && pieces[line][row - iterator].player == enemyColor) enemyPiece = true;
            iterator++;
        }

        enemyPiece = false;
        iterator = 0;
        while (row - iterator > 0 && line + iterator < rows) {
            if (enemyPiece && pieces[line + iterator][row - iterator].player == allyColor) {
                possiblePlay = true;
                if (color == "") turnPieces(line + iterator, row - iterator, line, row);
            } else if (iterator == 1 && pieces[line + iterator][row - iterator].player == enemyColor) enemyPiece = true;
            iterator++;
        }

        enemyPiece = false;
        iterator = 0;
        while (line + iterator < rows) {
            if (enemyPiece && pieces[line + iterator][row].player == allyColor) {
                possiblePlay = true;
                if (color == "") turnPieces(line + iterator, row, line, row);
            } else if (iterator == 1 && pieces[line + iterator][row].player == enemyColor) enemyPiece = true;
            iterator++;
        }

        enemyPiece = false;
        iterator = 0;
        while (row + iterator < rows && line + iterator < rows) {
            if (enemyPiece && pieces[line + iterator][row + iterator].player == allyColor) {
                possiblePlay = true;
                if (color == "") turnPieces(line + iterator, row + iterator, line, row);
            } else if (iterator == 1 && pieces[line + iterator][row + iterator].player == enemyColor) enemyPiece = true;
            iterator++;
        }
    }

    if (possiblePlay) {
        if (color == "") {
            freeze = true;
            var options = {};
            options["level"] = level;
            if (playerBlack) options["orientation"] = "w";
            else if (!playerBlack) options["orientation"] = "b";
            queryGameboard(getOthelloBoard(), "Othello", options, setOthelloBoard);
        }
        else {
            colorPiece(line, row, color);
        }
    }
}

function colorPiece(line, row, color) {
    othelloBoard[line][row].trigger("Coloring", new Array(color));
}

function turnPieces(line1, row1, line2, row2) {
    while (line1 != line2 || row1 != row2) {
        othelloBoard[line1][row1].trigger("Populate");
        if (line1 != line2) line1 = nextNumber(line1, line2);
        if (row1 != row2) row1 = nextNumber(row1, row2);
    }
    othelloBoard[line2][row2].trigger("Populate");
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
            simpleOthelloBoard[i].push(othelloBoard[i][j].playerDirection);
        }
    }
    return simpleOthelloBoard;
}

function setOthelloBoard(simpleOthelloBoard, playerTurn) {
    if (simpleOthelloBoard == "true") renderOthelloGameOver("Computer won!");
    else if (simpleOthelloBoard == "false") renderOthelloGameOver("Player won!");
    else {
        for (var i = 0; i < simpleOthelloBoard.length; i++) {
            for (var j = 0; j < simpleOthelloBoard[i].length; j++) {
                othelloBoard[i][j].trigger("PopulateByColor", new Array(simpleOthelloBoard[i][j]));
            }
        }

        freeze = false;
    }
}


