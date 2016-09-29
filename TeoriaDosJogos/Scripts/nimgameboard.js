function setupNim() {
    window.stickBoard = [];
    window.board = [];
    window.freeze = false;
    window.varianceX = 40, varianceY = 50, startX = 10, startY = 10, w = 20, h = 40;
    window.level = parseInt(getParameterByName("level")) || 1;
    window.miserie = (getParameterByName("miserie") === "true") || "Normal";
    window.lines = parseInt(getParameterByName("lines")) || 3;
    window.firstLine = parseInt(getParameterByName("firstLine")) || 3;
    window.increaseByLine = parseInt(getParameterByName("increaseByLine")) || 2;
    window.firstPlayer = getParameterByName("firstPlayer") || "Primeiro";
    startMenuNim();
}

function startMenuNim() {
    var dimensionX = 500;
    var dimensionY = 500;
    Crafty.init(dimensionX, dimensionY, document.getElementById('gameboard'));
    renderNimStartMenu();
    renderNimSelectors();
}

function renderNimStartMenu() {
    var menuX = 200;
    var menuY = 300;

    Crafty.e("2D, Canvas, Color")
    .attr({ x: startX, y: startY, w: board[0] * w, h: board.length * h })
    .color("white")
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: menuX, y: menuY })
    .text("Nim")
    .textColor("black")
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Color, Mouse")
    .attr({ x: menuX, y: menuY + 20, w: 70, h: 30 })
    .color("orange")
    .bind("MouseUp", function () { initNimGame() })
    .bind("MouseOver", function () { this.color("red") })
    .bind("MouseOut", function () { this.color("orange") })
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: menuX + 10, y: menuY + 30 })
    .text("Start game!")
    .textColor("black")
    .bind("DestroyMenu", function () { this.destroy() });
}

function renderNimGameOver(message) {
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
        setupNim();
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

function renderNimSelectors() {
    var selectorX = 50;
    var selectorY = 50;
    var height = 35;
    var spacing = 100;

    createArraySelector("Dificuldade", "level", spacing, [0, 1, 2], 1, selectorX, selectorY);
    selectorY = selectorY + height;
    createArraySelector("Modo de Jogo", "miserie", spacing, ["Normal", "Miséria"], 0, selectorX, selectorY);
    selectorY = selectorY + height;
    createArraySelector("Linhas", "lines", spacing, [3, 4, 5, 6], 0, selectorX, selectorY);
    selectorY = selectorY + height;
    createArraySelector("Primeira Linha", "firstLine", spacing, [1, 2, 3, 4, 5], 2, selectorX, selectorY);
    selectorY = selectorY + height;
    createArraySelector("Aumento por Linha", "increaseByLine", spacing, [1, 2, 3], 1, selectorX, selectorY);
    selectorY = selectorY + height;
    createArraySelector("Player", "firstPlayer", spacing, ["Primeiro", "Segundo"], 0, selectorX, selectorY);
}

function initNimGame() {
    Crafty.trigger("DestroyMenu");
    Crafty.trigger("DestroySelector");
    nimBoardGenerator(lines, firstLine, increaseByLine);
    sticksPositioner();
}

function nimBoardGenerator(lines, firstLine, factorUp) {
    while (lines > 0) {
        board.unshift(firstLine);
        firstLine = firstLine + factorUp;
        lines--;
    }
}

function sticksPositioner() {
    var lines = board.length;
    var y = startY;
    var lines = 0;
    var rows;
    var stickBoardIndex = 0;
    while (lines <= board.length) {
        var x = startX;
        rows = 0;
        stickBoard.push([]);
        while (rows < board[lines]) {
            stick = Crafty.e("2D, Canvas, Color, Mouse")
            .attr({ x: x, y: y, w: w, h: h })
            .color("black")
            .bind("Delete", function () {
                this.color("white");
                this.destroyed = true;
                this.status = "e";
            })
            .bind("Undelete", function () {
                this.color("black");
                this.destroyed = false;
            })
            .bind("Click", function () { if(!freeze && !this.destroyed) deleteSticks(this.line, this.row) });

            stick["line"] = lines;
            stick["row"] = rows;
            stick["destroyed"] = false;
            checker["status"] = "p";

            stickBoard[stickBoardIndex].push(stick);
            x = x + varianceX;
            rows++;
        }

        stickBoardIndex++;
        y = y + varianceY;
        lines++;    
    }
}

function deleteSticks(line, row) {
    if (line <= stickBoard.length) {
        var lineLength = stickBoard[line].length;
        if (row < lineLength) {
            board[line] = row;
            while (row < lineLength) {
                stickBoard[line][row].trigger("Delete");
                row++;
            }
        }
    }

    var options = {};
    options["level"] = level;
    options["miserie"] = miserie;
    if (firstPlayer == "Primeiro") options["orientation"] = "b";
    else if (firstPlayer == "Segundo") options["orientation"] = "a";
    freeze = true;
    queryGameboard(getPrologNimBoard(), "Nim", options, setNimBoard);
}

function getPrologNimBoard() {
    var prologNimBoard = [];
    var boardSize = firstLine + increaseByLine * (lines - 1);
    var iterator = 0;
    for (var i = 0; i < boardSize; i++) {
        prologNimBoard.push([]);
        if (i + 1 == firstLine + increaseByLine * iterator) {
            for (var j = 0; j < boardSize; j++) {
                if (j < stickBoard[stickBoard.length - 2 - iterator].length) {
                    prologNimBoard[i].push(stickBoard[lines - 1 - iterator][j].status);
                } else {
                    prologNimBoard[i].push('n');
                }
            }
            iterator++;
        } else {
            for (var j = 0; j < boardSize; j++) {
                prologNimBoard[i].push('n');
            }
        }
    }

    return prologNimBoard;
}

function getNimBoard() {
    var simpleNimBoard = [];
    for (var i = 0; i < stickBoard.length - 1; i++) {
        simpleNimBoard.push([]);
        for (var j = 0; j < stickBoard[i].length; j++) {
            simpleNimBoard[i].push(stickBoard[i][j].destroyed);
        }
    }
    return simpleNimBoard;
}

function setNimBoard(prologNimBoard) {
    simpleNimBoard = NimPrologToBoard(prologNim2DBoard);
    if (simpleNimBoard == "false") renderNimGameOver("Computer won!");
    else if (simpleNimBoard == "true") renderNimGameOver("Player won!");
    else {
        for (var i = 0; i < simpleNimBoard.length; i++) {
            for (var j = 0; j < simpleNimBoard[i].length; j++) {
                if (simpleNimBoard[i][j] == false) stickBoard[i][j].trigger("Undelete");
                else if (simpleNimBoard[i][j] == true) stickBoard[i][j].trigger("Delete");
            }
        }
    }

    freeze = false;
}
