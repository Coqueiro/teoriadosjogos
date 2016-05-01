using Newtonsoft.Json;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
using TeoriaDosJogos.Models;

namespace TeoriaDosJogos.Controllers
{
    public class PrologController : Controller
    {
        //public async Task GameIntel(GameboardModel gameboardModel)
        public GameboardModel GameIntel(GameboardModel gameboardModel)
        {
            return gameboardModel;
            //var content = new StringContent(JsonConvert.SerializeObject(gameboardModel), Encoding.UTF8, "application/json");
            //await new HttpClient.PostAsync("/", content);
        }
    }
}