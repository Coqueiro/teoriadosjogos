using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using SbsSW.SwiPlCs;

namespace TeoriaDosJogos.Services
{
    public static class PrologIntegration
    {
        public static string LoadEnvironment(string gameboard)
        {
            Environment.SetEnvironmentVariable("SWI_HOME_DIR", @"C:\Users\kartg\OneDrive\Documentos\swipl");
            Environment.SetEnvironmentVariable("Path", @"C:\Users\kartg\OneDrive\Documentos\swipl");
            Environment.SetEnvironmentVariable("Path", @"C:\Users\kartg\OneDrive\Documentos\swipl\bin");

            if (!PlEngine.IsInitialized)
            {
                string[] p = { "-q", "-f", @"C:/Users/kartg/OneDrive/Documentos/GitHub/teoriadosjogos/TeoriaDosJogos/Services/domineering.pl" };
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