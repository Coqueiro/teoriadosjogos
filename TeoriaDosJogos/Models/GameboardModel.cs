using Newtonsoft.Json;

namespace TeoriaDosJogos.Models
{
    public class GameboardModel
    {
        [JsonProperty("game")]
        public string Game { get; set; }

        [JsonProperty("gameboard")]
        public string[][] Gameboard { get; set; }
    }
}
