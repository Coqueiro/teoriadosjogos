function setupNim2D() {
    window.checkerBoard = [];
    window.board = [];
    window.freeze = false;
    window.varianceX = 60, varianceY = 60, startX = 10, startY = 10, contourLength = 3, w = 40, h = 40;
    window.level = parseInt(getParameterByName("level")) || 1;
    window.misere = (getParameterByName("misere") === "normal") || "normal";
    window.lines = parseInt(getParameterByName("lines")) || 3;
    window.firstLine = parseInt(getParameterByName("firstLine")) || 3;
    window.increaseByLine = parseInt(getParameterByName("increaseByLine")) || 2;
    window.firstPlayer = getParameterByName("firstPlayer") || "Primeiro";
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
    var menuY = 300;

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

function renderNim2DGameOver(message) {
    Crafty.e("2D, Canvas, Color")
    .attr({ x: startX, y: startY, w: (firstLine + (lines - 1) * increaseByLine) * (w + contourLength) + contourLength, h: board.length * (h + contourLength) + contourLength })
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
        setupNim2D();
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

function renderNim2DSelectors() {
    var selectorX = 50;
    var selectorY = 50;
    var height = 35;
    var spacing = 100;

    createArraySelector("Dificuldade", "level", spacing, [1, 2, 3], 1, selectorX, selectorY);
    selectorY = selectorY + height;
    createArraySelector("Modo de Jogo", "misere", spacing, ["normal", "misere"], 0, selectorX, selectorY);
    selectorY = selectorY + height;
    createArraySelector("Linhas", "lines", spacing, [3, 4, 5, 6], 0, selectorX, selectorY);
    selectorY = selectorY + height;
    createArraySelector("Primeira Linha", "firstLine", spacing, [1, 2, 3, 4, 5], 2, selectorX, selectorY);
    selectorY = selectorY + height;
    createArraySelector("Aumento por Linha", "increaseByLine", spacing, [1, 2, 3], 1, selectorX, selectorY);
    selectorY = selectorY + height;
    createArraySelector("Player", "firstPlayer", spacing, ["Primeiro", "Segundo"], 0, selectorX, selectorY);
}

function initNim2DGame() {
    Crafty.trigger("DestroyMenu");
    Crafty.trigger("DestroySelector");
    nim2DBoardGenerator(lines, firstLine, increaseByLine);
    checkersPositioner();
    if (firstPlayer == "Segundo") {
        freeze = true;
        var options = {};
        options["level"] = level;
        options["misere"] = misere;
        options["orientation"] = "a";
        queryGameboard(getPrologNim2DBoard(), "Nim2D", options, setNim2DBoard);
    };
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
                    this.status = "e";
                }
            })
            .bind("Undelete", function() {
                if (this.destroyed) {
                    this.selected = false;
                    this.color("black");
                    this.destroyed = false;
                    this.status = "p";
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
                if(!this.destroyed && freeze == false) {
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
            })
            .bind("Terminate", function () { this.destroy() });;

            checker["line"] = lines;
            checker["row"] = rows;
            checker["selected"] = false;
            checker["destroyed"] = false;
            checker["status"] = "p";

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
        freeze = true;
        var options = {};
        options["level"] = level;
        options["misere"] = misere;
        if (firstPlayer == "Primeiro") options["orientation"] = "b";
        else if (firstPlayer == "Segundo") options["orientation"] = "a";
        queryGameboard(getPrologNim2DBoard(), "Nim2D", options, setNim2DBoard);
    }
}

function getPrologNim2DBoard() {
    var prologNim2DBoard = [];
    var boardSize = firstLine + increaseByLine * (lines - 1);
    var iterator = 0;
    for (var i = 0; i < boardSize; i++) {
        prologNim2DBoard.push([]);
        if (i + 1 == firstLine + increaseByLine * iterator) {
            for (var j = 0; j < boardSize; j++) {
                if (j < checkerBoard[checkerBoard.length - 2 - iterator].length) {
                    prologNim2DBoard[i].push(checkerBoard[lines - 1 - iterator][j].status);
                } else {
                    prologNim2DBoard[i].push('n');
                }
            }
            iterator++;
        } else {
            for (var j = 0; j < boardSize; j++) {
                prologNim2DBoard[i].push('n');
            }
        }
    }

    return prologNim2DBoard;
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

function NimPrologToBoard(prologNim2DBoard) {
    if (prologNim2DBoard == "true" || prologNim2DBoard == "false") return prologNim2DBoard;
    else {
        var simpleNim2DBoard = [];
        var boardSize = firstLine + increaseByLine * (lines - 1);
        var iterator = 0;
        for (var i = 0; i < boardSize; i++) {
            if (i + 1 == firstLine + increaseByLine * iterator) {
                simpleNim2DLine = [];
                for(var j = 0; j < boardSize; j++) {
                    if (prologNim2DBoard[i][j] == "p") simpleNim2DLine.push(false);
                    else if (prologNim2DBoard[i][j] == "e") simpleNim2DLine.push(true);
                }

                iterator++;
                simpleNim2DBoard.unshift(simpleNim2DLine);
            }
        }

        return simpleNim2DBoard;
    }
}

function setNim2DBoard(prologNim2DBoard) {
    simpleNim2DBoard = NimPrologToBoard(prologNim2DBoard);
    if (simpleNim2DBoard == "false") renderNim2DGameOver("Computer won!");
    else if (simpleNim2DBoard == "true") renderNim2DGameOver("Player won!");
    else {
        for (var i = 0; i < simpleNim2DBoard.length; i++) {
            for (var j = 0; j < simpleNim2DBoard[i].length; j++) {
                if (simpleNim2DBoard[i][j] == false) checkerBoard[i][j].trigger("Undelete");
                else if (simpleNim2DBoard[i][j] == true) checkerBoard[i][j].trigger("Delete");
            }
        }

        freeze = false;
    }
}
    
