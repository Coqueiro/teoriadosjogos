using Newtonsoft.Json;

namespace TeoriaDosJogos.Models
{
    public class GameboardModel
    {
        [JsonProperty("game")]
        public string Game { get; set; }

        [JsonProperty("gameboard")]
        public string[][] Gameboard { get; set; }

        [JsonProperty("level")]
        public int Level { get; set; }

        [JsonProperty("miserie")]
        public string Miserie { get; set; }

        [JsonProperty("orientation")]
        public string Orientation { get; set; }
    }
}
