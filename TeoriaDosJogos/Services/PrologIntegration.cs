using SbsSW.SwiPlCs;
using System;

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

        public static string DomineeringPlay(string gameboard, int level)
        {
            var projectPath = System.AppDomain.CurrentDomain.BaseDirectory;

            LoadEnvironment(projectPath);
            if (!PlEngine.IsInitialized)
            {
                string[] p = { "-q", "-f", projectPath + @"Services\\domineering.pl" };
                PlEngine.Initialize(p);
            }

            var answer = "";
            using (PlQuery q = new PlQuery("computerH, playComputer(NewBoard, h, b(" + gameboard + "), " + level + ")"))
            {
                foreach (PlQueryVariables v in q.SolutionVariables)
                {
                    answer = v["NewBoard"].ToString();
                }
            }

            PlEngine.PlCleanup();

            return answer;
        }
    }
}