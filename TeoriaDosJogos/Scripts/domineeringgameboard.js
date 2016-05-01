function setupDomineering() {
    window.domineeringBoard = [];
    window.board = [];
    window.playerNorth = true;
    window.startX = 10, startY = 10, contourLength = 3, w = 40, h = 40;
    if (typeof level == "undefined") window.level = parseInt(getParameterByName("level")) || 0;
    if (typeof lines == "undefined") window.lines = parseInt(getParameterByName("lines")) || 8;
    if (typeof rows == "undefined") window.rows = parseInt(getParameterByName("rows")) || 8;
    startMenuDomineering();
}

function startMenuDomineering() {
    var dimensionX = 500;
    var dimensionY = 500;
    Crafty.init(dimensionX, dimensionY, document.getElementById('gameboard'));
    renderDomineeringStartMenu();
    renderDomineeringSelectors();
}

function renderDomineeringStartMenu() {
    Crafty.e("2D, Canvas, Color")
    .attr({ x: startX, y: startY, w: board[0] * (w + contourLength) + contourLength, h: board.length * (h + contourLength) + contourLength })
    .color("white")
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 200, y: 200 })
    .text("Domineering")
    .textColor("black")
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Color, Mouse")
    .attr({ x: 200, y: 220, w: 70, h: 30 })
    .color("orange")
    .bind("MouseUp", function () { initDomineeringGame() })
    .bind("MouseOver", function () { this.color("red") })
    .bind("MouseOut", function () { this.color("orange") })
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 210, y: 230 })
    .text("Start game!")
    .textColor("black")
    .bind("DestroyMenu", function () { this.destroy() });
}

function renderDomineeringSelectors() {
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

function initDomineeringGame() {
    Crafty.trigger("DestroyMenu");
    Crafty.trigger("DestroySelector");
    domineeringBoardGenerator(lines, rows);
    domineeringBoardRender();
}

function domineeringBoardGenerator(lines, rows) {
    while (lines > 0) {
        board.push(rows);
        lines--;
    }
}

function domineeringBoardRender() {
    var y = startY + contourLength;
    var lines = 0;
    var rows;
    var domineeringBoardIndex = 0;

    Crafty.e("2D, Canvas, Color")
    .attr({ x: startX, y: startY, w: board[0] * (w + contourLength) + contourLength, h: board.length * (h + contourLength) + contourLength })
    .color("black");

    while (lines <= board.length) {
        var x = startX + contourLength;
        rows = 0;
        domineeringBoard.push([]);
        while (rows < board[lines]) {
            domino = Crafty.e("2D, Canvas, Color, Mouse")
            .attr({ x: x, y: y, w: w, h: h })
            .color("white")
            .bind("Delete", function () { this.destroy() })
            .bind("Populate", function (args) {
                this.color(args[0]);
                if (args[0] == "blue") this.playerDirection = "vertical";
                else if (args[0] == "yellow") this.playerDirection = "horizontal";
                this.populated = true;
            })
            .bind("Unpopulate", function() {
                this.color("white");
                this.playerDirection = "";
                this.populated = false;
            })
            .bind("MouseUp", function () { dominoPlacer(this.line, this.row) });

            domino["line"] = lines;
            domino["row"] = rows;
            domino["populated"] = false;
            domino["playerDirection"] = "";

            domineeringBoard[domineeringBoardIndex].push(domino);
            x += w + contourLength;
            rows++;
        }

        domineeringBoardIndex++;
        y += h + contourLength;
        lines++;    
    }
}

function dominoPlacer(line, row) {
    if (!domineeringBoard[line][row].populated) {
        if (playerNorth) {
            if (!domineeringBoard[line - 1][row].populated) {
                domineeringBoard[line][row].trigger("Populate", new Array("blue"));
                domineeringBoard[line - 1][row].trigger("Populate", new Array("blue"));
                playerNorth = !playerNorth;
                sendGameboard(getDomineeringBoard(), "Domineering");
            }
        } else {
            if (!domineeringBoard[line][row + 1].populated) {
                domineeringBoard[line][row].trigger("Populate", new Array("yellow"));
                domineeringBoard[line][row + 1].trigger("Populate", new Array("yellow"));
                playerNorth = !playerNorth;
                sendGameboard(getDomineeringBoard(), "Domineering");
            }
        }
    }
}

function getDomineeringBoard() {
    var simpleDomineeringBoard = [];
    for (var i = 0; i < domineeringBoard.length - 1; i++) {
        simpleDomineeringBoard.push([]);
        for (var j = 0; j < domineeringBoard[i].length; j++) {
            simpleDomineeringBoard[i].push(domineeringBoard[i][j].playerDirection);
        }
    }

    return simpleDomineeringBoard;
}

function setDomineeringBoard(simpleDomineeringBoard, playerTurn) {
    for (var i = 0; i < simpleDomineeringBoard.length; i++) {
        for (var j = 0; j < simpleDomineeringBoard[i].length; j++) {
            if (simpleDomineeringBoard[i][j] == "vertical") domineeringBoard[i][j].trigger("Populate", new Array("blue"));
            else if (simpleDomineeringBoard[i][j] == "horizontal") domineeringBoard[i][j].trigger("Populate", new Array("yellow"));
            else if (simpleDomineeringBoard[i][j] == "") domineeringBoard[i][j].trigger("Unpopulate");
        }
    }

    if (playerTurn == "north") playerNorth = true;
    else if (playerTurn == "east") playerNorth = false;
}
    
