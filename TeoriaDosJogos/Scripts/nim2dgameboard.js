﻿function setupNim2D() {
    window.checkerBoard = [];
    window.board = [];
    window.playerSwitch = true;
    window.varianceX = 60, varianceY = 60, startX = 10, startY = 10, w = 40, h = 40;
    window.level = parseInt(getParameterByName("level")) || 0;
    window.miserie = (getParameterByName("miserie") === "true") || false;
    window.lines = parseInt(getParameterByName("lines")) || 3;
    window.firstLine = parseInt(getParameterByName("firstLine")) || 3;
    window.increaseByLine = parseInt(getParameterByName("increaseByLine")) || 2;
    startMenuNim2D();
}

function startMenuNim2D() {
    var dimensionX = 500;
    var dimensionY = 500;
    nim2DBoardGenerator(lines, firstLine, increaseByLine);
    Crafty.init(dimensionX, dimensionY, document.getElementById('gameboard'));
    renderNim2DStartMenu();
}

function renderNim2DStartMenu() {
    Crafty.e("2D, Canvas, Color")
    .attr({ x: startX, y: startY, w: board[0] * w, h: board.length * h })
    .color("white")
    .bind("DestroyMenu", function() { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 200, y: 200 })
    .text("Nim2D")
    .textColor("black")
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Color, Mouse")
    .attr({ x: 200, y: 220, w: 70, h: 30 })
    .color("orange")
    .bind("MouseUp", function () { initNim2DGame() })
    .bind("MouseOver", function () { this.color("red") })
    .bind("MouseOut", function () { this.color("orange") })
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 210, y: 230 })
    .text("Start game!")
    .textColor("black")
    .bind("DestroyMenu", function () { this.destroy() });
}

function initNim2DGame() {
    Crafty.trigger("DestroyMenu");
    checkersPositioner();
}

function nim2DBoardGenerator(lines, firstLine, factorUp) {
    while (lines > 0) {
        board.unshift(firstLine);
        firstLine = firstLine + factorUp;
        lines--;
    }
}

function checkersPositioner() {
    var lines = board.length;
    var y = startY;
    var lines = 0;
    var rows;
    var checkerBoardIndex = 0;
    while (lines <= board.length) {
        var x = startX;
        rows = 0;
        checkerBoard.push([]);
        while (rows < board[lines]) {
            checker = Crafty.e("2D, Canvas, Color, Mouse")
            .attr({ x: x, y: y, w: w, h: h })
            .color("black")
            .bind("Delete", function () {
                if (!this.destroyed) {
                    this.selected = false;
                    this.color("black");
                    this.destroy();
                    this.destroyed = true;
               }
            })
            .bind("Select", function () {
                this.color("red");
                this.selected = true;
            })
            .bind("Unselect", function () {
                this.color("black");
                this.selected = false;
            })
            .bind("MouseUp", function (mouseEvent) {
                if (mouseEvent.mouseButton === Crafty.mouseButtons.RIGHT) {
                    this.trigger("Unselect");
                } else if (this.selected == false) {
                    this.trigger("Select");
                    var selectedCheckers = getSelectedCheckers();
                    if (selectedCheckers.length == 2) {
                        deleteCheckers(selectedCheckers[0].line, selectedCheckers[0].row, selectedCheckers[1].line, selectedCheckers[1].row);
                    }
                } else {
                    var selectedCheckers = getSelectedCheckers();
                    if (selectedCheckers.length == 1) {
                        deleteCheckers(selectedCheckers[0].line, selectedCheckers[0].row, selectedCheckers[0].line, selectedCheckers[0].row);
                    }
                }
            });

            checker["line"] = lines;
            checker["row"] = rows;
            checker["selected"] = false;
            checker["destroyed"] = false;

            checkerBoard[checkerBoardIndex].push(checker);
            x = x + varianceX;
            rows++;
        }

        checkerBoardIndex++;
        y = y + varianceY;
        lines++;    
    }
}

function getSelectedCheckers() {
    var selectedCheckers = [];
    checkerBoard.forEach(function(checkerLine) {
        checkerLine.forEach(function(checker) {
            if(checker.selected == true) {
                var checker = { line: checker.line, row: checker.row };
                selectedCheckers.push(checker);
            }
        })
    });
    
    return selectedCheckers;
}

function deleteCheckers(line, row, line2, row2) {

    var markedCheckers = [];

    if (line <= checkerBoard.length
        && line2 < checkerBoard.length) {
        var underChecker, overChecker;
        if (line == line2) {
            if (row <= row2) {
                underChecker = row;
                overChecker = row2;
            } else {
                overChecker = row;
                underChecker = row2;
            }

            while (underChecker <= overChecker) {
                if (!checkerBoard[line][underChecker].destroyed) {
                    markedCheckers.push(checkerBoard[line][underChecker]);
                    board[line]--;
                } else {
                    markedCheckers = [];
                    break;
                }

                underChecker++;
            }
        } else if (row == row2) {
            if (line <= line2) {
                underChecker = line;
                overChecker = line2;
            } else {
                overChecker = line;
                underChecker = line2;
            }

            while (underChecker <= overChecker) {
                if (!checkerBoard[underChecker][row].destroyed) {
                    markedCheckers.push(checkerBoard[underChecker][row]);
                    board[underChecker]--;
                } else {
                    markedCheckers = [];
                    break;
                }

                underChecker++;
            }
        }

        Crafty.trigger("Unselect");
    }

    for (var i = 0; i < markedCheckers.length; i++)
    {
        markedCheckers[i].trigger("Delete");
    }
}
    
