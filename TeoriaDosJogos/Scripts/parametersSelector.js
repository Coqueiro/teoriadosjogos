function createArraySelector(selectorName, selectorVariable, spacing, selectorArray, defaultPosition, startX, startY) {
    var size = 30;
    var space = 5;

    var text = Crafty.e("2D, Canvas, Text")
    .attr({ x: startX, y: startY + size/3 })
    .text(selectorName)
    .textColor("black")
    .bind("DestroySelector", function () { this.destroy() });

    var decreaseButton = Crafty.e("2D, Canvas, Color, Mouse")
    .attr({ x: startX + spacing + space, y: startY, w: size, h: size })
    .color("orange")
    .bind("MouseUp", function () { Crafty.trigger("DecreaseArray", new Array(this.selectorName)) })
    .bind("MouseOver", function () { this.color("red") })
    .bind("MouseOut", function () { this.color("orange") })
    .bind("DestroySelector", function () { this.destroy() });

    decreaseButton["selectorName"] = selectorName;
    
    var increaseButton = Crafty.e("2D, Canvas, Color, Mouse")
    .attr({ x: startX + spacing + size + 2 * space, y: startY, w: size, h: size })
    .color("orange")
    .bind("MouseUp", function () { Crafty.trigger("IncreaseArray", new Array(this.selectorName)) })
    .bind("MouseOver", function () { this.color("red") })
    .bind("MouseOut", function () { this.color("orange") })
    .bind("DestroySelector", function () { this.destroy() });

    increaseButton["selectorName"] = selectorName;

    var selectorChoice = Crafty.e("2D, Canvas, Text")
    .attr({ x: startX + spacing + 2 * size + 3 * space, y: startY + size/3 })
    .text(selectorArray[defaultPosition])
    .textColor("black")
    .bind("DecreaseArray", function (args) {
        if (this.position > 0 && args[0] == this.selectorName) {
            this.text(this.selectorArray[--this.position]);
            window[this.selectorVariable] = this.selectorArray[this.position];
        }
    })
    .bind("IncreaseArray", function (args) {
        if (this.position < this.selectorArray.length - 1 && args[0] == this.selectorName) {
            this.text(this.selectorArray[++this.position]);
            window[this.selectorVariable] = this.selectorArray[this.position];
        }
    })
    .bind("DestroySelector", function () { this.destroy() });

    selectorChoice["position"] = defaultPosition;
    selectorChoice["selectorName"] = selectorName;
    selectorChoice["selectorVariable"] = selectorVariable;
    selectorChoice["selectorArray"] = selectorArray;
}

function destroyArraySelectors() {
    Crafty.trigger("DestroySelector");
}

