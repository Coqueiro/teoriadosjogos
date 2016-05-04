using SbsSW.SwiPlCs;
using System;

namespace TeoriaDosJogos.Services
{
    public static class PrologIntegration
    {
        public static string LoadEnvironment(string gameboard)
        {
            var projectPath = System.AppDomain.CurrentDomain.BaseDirectory;

            Environment.SetEnvironmentVariable("SWI_HOME_DIR", projectPath + @"swipl");
            Environment.SetEnvironmentVariable("Path", projectPath + @"swipl");
            Environment.SetEnvironmentVariable("Path", projectPath + @"swipl\bin");
            
            if (!PlEngine.IsInitialized)
            {
                string[] p = { "-q", "-f", projectPath + @"Services\\domineering.pl" };
                PlEngine.Initialize(p);
                //string[] p = { "-q" };
                //PlEngine.Initialize(p);
            }

            //PlQuery.PlCall("consult('C:/Users/kartg/OneDrive/Documentos/GitHub/teoriadosjogos/TeoriaDosJogos/Services/domineering.pl')");
            //using (PlQuery q = new PlQuery("computerH, playComputer(NewBoard, h, b(e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e), 2)"))

            var answer = "";
            using (PlQuery q = new PlQuery("computerH, playComputer(NewBoard, h, b(" + gameboard + "), 2)"))
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