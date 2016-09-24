using Newtonsoft.Json;
using System.Web.Mvc;
using TeoriaDosJogos.Helpers;
using TeoriaDosJogos.Models;
using TeoriaDosJogos.Services;

namespace TeoriaDosJogos.Controllers
{
    public class PrologController : Controller
    {
        [HttpPost]
        [ValidateInput(false)]
        public string GameIntel(GameboardModel gameboardModel)
        {
            var gameboardString = PrologUtils.GameboardToString(gameboardModel.Gameboard);
            var gameboardStringQuery = PrologIntegration.IAPlay(gameboardString, gameboardModel);
            if (gameboardStringQuery == "victory")
            {
                return JsonConvert.SerializeObject("true");
            }
            else if (gameboardStringQuery == "defeat")
            {
                return JsonConvert.SerializeObject("false");
            }
            else
            {
                var gameboardQuery = PrologUtils.StringToGameboard(gameboardStringQuery, Utils.LengthArray(gameboardModel.Gameboard));
                return JsonConvert.SerializeObject(gameboardQuery);
            }
        }
    }
}