using Newtonsoft.Json;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
using TeoriaDosJogos.Models;
using TeoriaDosJogos.Services;

namespace TeoriaDosJogos.Controllers
{
    public class PrologController : Controller
    {
        [HttpPost]
        public string GameIntel(GameboardModel gameboardModel)
        {
            var gameboardString = PrologUtils.GameboardToString(gameboardModel.Gameboard);            
            var gameboardStringQuery = PrologIntegration.LoadEnvironment(gameboardString);
            var gameboardQuery = PrologUtils.StringToGameboard(gameboardStringQuery);
            return JsonConvert.SerializeObject(gameboardQuery);
        }
    }
}