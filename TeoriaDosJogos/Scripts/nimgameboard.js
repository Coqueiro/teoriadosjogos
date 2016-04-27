var stickBoard = [];
var board = [];
var playerSwitch = true;
var varianceX = 40, varianceY = 120, startX = 10, startY = 10, w = 20, h = 100;
var level = parseInt(getParameterByName("level")) || 0;
var miserie = (getParameterByName("miserie") === "true") || false;
var lines = parseInt(getParameterByName("lines")) || 3;
var firstLine = parseInt(getParameterByName("firstLine")) || 3;
var increaseByLine = parseInt(getParameterByName("increaseByLine")) || 2;
startMenu();

function startMenu() {
    var dimensionX = 500;
    var dimensionY = 500;
    boardGenerator(lines, firstLine, increaseByLine);
    Crafty.init(dimensionX, dimensionY, document.getElementById('gameboard'));
    renderStartMenu();
}

function renderStartMenu() {
    Crafty.e("2D, Canvas, Color")
    .attr({ x: startX, y: startY, w: board[0] * w, h: board.length * h })
    .color("white")
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 200, y: 200 })
    .text("Nim")
    .textColor("black")
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Color, Mouse")
    .attr({ x: 200, y: 220, w: 70, h: 30 })
    .color("orange")
    .bind("MouseUp", function () { initGame() })
    .bind("MouseOver", function () { this.color("red") })
    .bind("MouseOut", function () { this.color("orange") })
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 210, y: 230 })
    .text("Start game!")
    .textColor("black")
    .bind("DestroyMenu", function () { this.destroy() });
}

function initGame() {
    Crafty.trigger("DestroyMenu");
    sticksPositioner();
}

function boardGenerator(lines, firstLine, factorUp) {
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
    
