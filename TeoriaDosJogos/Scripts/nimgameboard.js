function setupNim() {
    window.stickBoard = [];
    window.board = [];
    window.playerSwitch = true;
    window.varianceX = 40, varianceY = 120, startX = 10, startY = 10, w = 20, h = 100;
    if (typeof level == "undefined") window.level = parseInt(getParameterByName("level")) || 0;
    if (typeof miserie == "undefined") window.miserie = (getParameterByName("miserie") === "true") || "Normal";
    if (typeof lines == "undefined") window.lines = parseInt(getParameterByName("lines")) || 3;
    if (typeof firstLine == "undefined") window.firstLine = parseInt(getParameterByName("firstLine")) || 3;
    if (typeof increaseByLine == "undefined") window.increaseByLine = parseInt(getParameterByName("increaseByLine")) || 2;
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
    var menuY = 250;

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
            .bind("Delete", function () { this.destroy() })
            .bind("Click", function () { if(playerSwitch) deleteSticks(this.line, this.row) });

            stick["line"] = lines;
            stick["row"] = rows;

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

    console.log(board);
}
    
