function getParameterByName(name) {
    var url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}

function sendGameboard(gameboard, game) {

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
        }
    });
}