﻿using Newtonsoft.Json;
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
            else return "";
        }

        public string Domineering(GameboardModel gameboardModel)
        {
            var gameboardString = PrologUtils.GameboardToString(gameboardModel.Gameboard);
            var gameboardStringQuery = PrologIntegration.DomineeringPlay(gameboardString, gameboardModel.Level);
            var gameboardQuery = PrologUtils.StringToGameboard(gameboardStringQuery, Utils.LengthArray(gameboardModel.Gameboard));
            return JsonConvert.SerializeObject(gameboardQuery);
        }
    }
}