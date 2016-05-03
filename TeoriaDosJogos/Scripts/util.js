function getParameterByName(name) {
    var url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}

function queryGameboard(gameboard, game, orientation, callback) {

    var setData = {
        gameboard: gameboard,
        game: game
    }

    $.ajax({
        type: 'POST',
        url: '/Prolog/GameIntel',
        data: setData,
        dataType: "json",
        xhrFields: {
            withCredentials: true
        },
        success: function (data) {
            callback(data, orientation);
        }
    });
}