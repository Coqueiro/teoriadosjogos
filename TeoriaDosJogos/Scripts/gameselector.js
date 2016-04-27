var startX = 10;
var startY = 10;
var dimensionX = 500;
var dimensionY = 500;

renderGameMenu();

function renderGameMenu() {
    Crafty.init(dimensionX, dimensionY, document.getElementById('gameboard'));
    Crafty.e("2D, Canvas, Color")
    .attr({ x: startX, y: startY, w: dimensionX, h: dimensionY })
    .color("white")
    .bind("DestroyGameMenu", function () { this.destroy() });

    var initialY = 160;
    nimButton(initialY);
    initialY = initialY + 35;
    nim2DButton(initialY);
    initialY = initialY + 35;
    domineeringButton(initialY);
    initialY = initialY + 35;
    othelloButton(initialY);
}

function nimButton(initialY) {
    Crafty.e("2D, Canvas, Color, Mouse")
    .attr({ x: 200, y: initialY + 20, w: 70, h: 30 })
    .color("orange")
    .bind("MouseUp", function () {
        setupNim();
        Crafty.trigger("DestroyGameMenu");
    })
    .bind("MouseOver", function () { this.color("red") })
    .bind("MouseOut", function () { this.color("orange") })
    .bind("DestroyGameMenu", function () { this.destroy(); });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 210, y: initialY +30 })
    .text("Start Nim!")
    .textColor("black")
    .bind("DestroyGameMenu", function () { this.destroy() });
}

function nim2DButton(initialY) {
    Crafty.e("2D, Canvas, Color, Mouse")
    .attr({ x: 200, y: initialY + 20, w: 70, h: 30 })
    .color("orange")
    .bind("MouseUp", function () {
        setupNim2D();
        Crafty.trigger("DestroyGameMenu");
    })
    .bind("MouseOver", function () { this.color("red") })
    .bind("MouseOut", function () { this.color("orange") })
    .bind("DestroyGameMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 210, y: initialY + 30 })
    .text("Start Nim2D!")
    .textColor("black")
    .bind("DestroyGameMenu", function () { this.destroy() });
}

function domineeringButton(initialY) {
    Crafty.e("2D, Canvas, Color, Mouse")
    .attr({ x: 200, y: initialY + 20, w: 70, h: 30 })
    .color("orange")
    .bind("MouseUp", function () {
        setupDomineering();
        Crafty.trigger("DestroyGameMenu");
    })
    .bind("MouseOver", function () { this.color("red") })
    .bind("MouseOut", function () { this.color("orange") })
    .bind("DestroyGameMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 210, y: initialY + 30 })
    .text("Start Domineering!")
    .textColor("black")
    .bind("DestroyGameMenu", function () { this.destroy() });
}


function othelloButton(initialY) {
    Crafty.e("2D, Canvas, Color, Mouse")
    .attr({ x: 200, y: initialY + 20, w: 70, h: 30 })
    .color("orange")
    .bind("MouseUp", function () {
        setupOthello();
        Crafty.trigger("DestroyGameMenu");
    })
    .bind("MouseOver", function () { this.color("red") })
    .bind("MouseOut", function () { this.color("orange") })
    .bind("DestroyGameMenu", function () { this.destroy() });

    Crafty.e("2D, Canvas, Text")
    .attr({ x: 210, y: initialY + 30 })
    .text("Start Othello!")
    .textColor("black")
    .bind("DestroyGameMenu", function () { this.destroy() });
}

