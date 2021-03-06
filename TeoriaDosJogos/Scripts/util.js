﻿function getParameterByName(name) {
    var url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}

function queryGameboard(gameboard, game, options, callback) {

    var setData = {
        gameboard: gameboard,
        game: game
    }

    if (options.level != undefined) setData["level"] = options.level;
    if (options.misere != undefined) setData["misere"] = options.misere;
    if (options.orientation != undefined) setData["orientation"] = options.orientation;

    $.ajax({
        type: 'POST',
        url: '/Prolog/GameIntel',
        data: setData,
        dataType: "json",
        xhrFields: {
            withCredentials: true
        },
        success: function (data) {
            if (game == "Domineering") callback(data, options.orientation);
            else if (game == "Othello") callback(data, options.orientation);
            else if (game == "Nim2D") callback(data);
            else if (game == "Nim") callback(data);
        }
    });
}