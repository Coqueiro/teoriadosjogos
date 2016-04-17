﻿var domineeringBoard = [];
var board = [];
var playerSwitch = true;
var playerNorth = true;
var startX = 10, startY = 10, contourLength = 3, w = 40, h = 40;
startMenu();

function startMenu() {
    var dimensionX = 500;
    var dimensionY = 500;
    var lines = 8;
    var rows = 8;
    boardGenerator(lines, rows);
    Crafty.init(dimensionX, dimensionY, document.getElementById('gameboard'));
    renderStartMenu();
}

function renderStartMenu() {
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
    domineeringBoardRender();
}

function boardGenerator(lines, rows) {
    while (lines > 0) {
        board.push(rows);
        lines--;
    }
}

function domineeringBoardRender() {
    var lines = board.length;
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
            .bind("Populate", function () {
                if (playerNorth) this.color("blue");
                else this.color("yellow");
                this.populated = true;
            })
            .bind("MouseUp", function () { dominoPlacer(this.line, this.row) });

            domino["line"] = lines;
            domino["row"] = rows;
            domino["populated"] = false;

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
                domineeringBoard[line][row].trigger("Populate");
                domineeringBoard[line - 1][row].trigger("Populate");
                playerNorth = !playerNorth;
            }
        } else {
            if (!domineeringBoard[line][row + 1].populated) {
                domineeringBoard[line][row].trigger("Populate");
                domineeringBoard[line][row + 1].trigger("Populate");
                playerNorth = !playerNorth;
            }
        }
    }
}
    
