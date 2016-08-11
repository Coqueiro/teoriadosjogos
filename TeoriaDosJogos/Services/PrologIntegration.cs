using SbsSW.SwiPlCs;
using System;
using TeoriaDosJogos.Models;

namespace TeoriaDosJogos.Services
{
    public static class PrologIntegration
    {
        public static void LoadEnvironment(string projectPath)
        {
            Environment.SetEnvironmentVariable("SWI_HOME_DIR", projectPath + @"swipl");
            Environment.SetEnvironmentVariable("Path", projectPath + @"swipl");
            Environment.SetEnvironmentVariable("Path", projectPath + @"swipl\\bin");
        }

        public static string GameFile(string game)
        {
            if (game == "Domineering") return "domineering";
            else if (game == "Nim2D") return "nim2d";
            else return "";
        }

        public static string ComputerName(string game)
        {
            if (game == "Domineering") return "computerH";
            else if (game == "Nim2D") return "computerA";
            else return "";
        }

        public static string IAPlay(string gameboard, GameboardModel gameboardModel)
        {
            var projectPath = System.AppDomain.CurrentDomain.BaseDirectory;

            LoadEnvironment(projectPath);
            if (!PlEngine.IsInitialized)
            {
                string[] p = { "-q", "-f", projectPath + @"Services\\" + GameFile(gameboardModel.Game) + ".pl" };
                PlEngine.Initialize(p);
            }

            var answer = "";
            var query = ComputerName(gameboardModel.Game) + ", setBoardSize(" + gameboardModel.Gameboard.Length + "), playComputer(NewBoard, " + gameboardModel.Orientation + ", b(" + gameboard + "), " + gameboardModel.Level + ", Victory, Defeat)";
            using (PlQuery q = new PlQuery(query))
            {
                foreach (PlQueryVariables v in q.SolutionVariables)
                {
                    if (v["Defeat"].ToString() == "true") answer = "defeat";
                    else if (v["Victory"].ToString() == "true") answer = "victory";
                    else answer = v["NewBoard"].ToString();
                }
            }

            PlEngine.PlCleanup();

            return answer;
        }
    }
}