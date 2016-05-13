function setupNim2D() {
    window.checkerBoard = [];
    window.board = [];
    window.varianceX = 60, varianceY = 60, startX = 10, startY = 10, w = 40, h = 40;
    if (typeof level == "undefined") window.level = parseInt(getParameterByName("level")) || 0;
    if (typeof miserie == "undefined") window.miserie = (getParameterByName("miserie") === "true") || "Normal";
    if(typeof lines == "undefined") window.lines = parseInt(getParameterByName("lines")) || 3;
    if (typeof firstLine == "undefined") window.firstLine = parseInt(getParameterByName("firstLine")) || 3;
    if (typeof increaseByLine == "undefined") window.increaseByLine = parseInt(getParameterByName("increaseByLine")) || 2;
    startMenuNim2D();
}

function startMenuNim2D() {
    var dimensionX = 500;
    var dimensionY = 500;
    Crafty.init(dimensionX, dimensionY, document.getElementById('gameboard'));
    renderNim2DStartMenu();
    renderNim2DSelectors();
}

function renderNim2DStartMenu() {
    var menuX = 200;
    var menuY = 250;

    Crafty.e("2D, Canvas, Color")
    .attr({ x: startX, y: startY, w: board[0] * w, h: board.length * h })
    .color("white")
    .bind("DestroyMenu", function() { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: menuX, y: menuY })
    .text("Nim2D")
    .textColor("black")
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Color, Mouse")
    .attr({ x: menuX, y: menuY + 20, w: 70, h: 30 })
    .color("orange")
    .bind("MouseUp", function () { initNim2DGame() })
    .bind("MouseOver", function () { this.color("red") })
    .bind("MouseOut", function () { this.color("orange") })
    .bind("DestroyMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: menuX + 10, y: menuY + 30 })
    .text("Start game!")
    .textColor("black")
    .bind("DestroyMenu", function () { this.destroy() });
}

function renderNim2DSelectors() {
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

function initNim2DGame() {
    Crafty.trigger("DestroyMenu");
    Crafty.trigger("DestroySelector");
    nim2DBoardGenerator(lines, firstLine, increaseByLine);
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
                    this.color("white");
                    this.destroyed = true;
                }
            })
            .bind("Undelete", function() {
                if (this.destroyed) {
                    this.selected = false;
                    this.color("black");
                    this.destroyed = false;
                }
            })
            .bind("Select", function () {
                if (!this.destroyed) {
                    this.color("red");
                    this.selected = true;
                }
            })
            .bind("Unselect", function () {
                if (!this.destroyed) {
                    this.color("black");
                    this.selected = false;
                }
            })
            .bind("MouseUp", function (mouseEvent) {
                if(!this.destroyed) {
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

    if (markedCheckers.length > 0) {
        var options = {};
        options["level"] = level;
        options["miserie"] = miserie;
        queryGameboard(getNim2DBoard(), "Nim2D", options, setNim2DBoard);
    }
}


function getNim2DBoard() {
    var simpleNim2DBoard = [];
    for (var i = 0; i < checkerBoard.length - 1; i++) {
        simpleNim2DBoard.push([]);
        for (var j = 0; j < checkerBoard[i].length; j++) {
            simpleNim2DBoard[i].push(checkerBoard[i][j].destroyed);
        }
    }
    return simpleNim2DBoard;
}

function setNim2DBoard(simpleNim2DBoard) {
    for (var i = 0; i < simpleNim2DBoard.length; i++) {
        for (var j = 0; j < simpleNim2DBoard[i].length; j++) {
            if (simpleNim2DBoard[i][j] == false) checkerBoard[i][j].trigger("Undelete");
            else if (simpleNim2DBoard[i][j] == true) checkerBoard[i][j].trigger("Delete");
        }
    }
}
    
