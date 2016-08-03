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
        public string GameIntel(GameboardModel gameboardModel)
        {
            if (gameboardModel.Game == "Domineering") return Domineering(gameboardModel);
            else if (gameboardModel.Game == "Nim2D") return Nim2D(gameboardModel);
            else return "";
        }

        public string Domineering(GameboardModel gameboardModel)
        {
            var gameboardString = PrologUtils.GameboardToString(gameboardModel.Gameboard);
            var gameboardStringQuery = PrologIntegration.DomineeringPlay(gameboardString, gameboardModel);
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

        public string Nim2D(GameboardModel gameboardModel)
        {
            var gameboardString = PrologUtils.GameboardToString(gameboardModel.Gameboard);
            var gameboardStringQuery = PrologIntegration.Nim2DPlay(gameboardString, gameboardModel);
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