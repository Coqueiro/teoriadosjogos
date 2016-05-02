using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using SbsSW.SwiPlCs;

namespace TeoriaDosJogos.Services
{
    public static class PrologIntegration
    {
        public static void LoadEnvironment()
        {
            Environment.SetEnvironmentVariable("SWI_HOME_DIR", @"C:\Users\kartg\OneDrive\Documentos\swipl");
            Environment.SetEnvironmentVariable("Path", @"C:\Users\kartg\OneDrive\Documentos\swipl");
            Environment.SetEnvironmentVariable("Path", @"C:\Users\kartg\OneDrive\Documentos\swipl\bin");
            //string[] p = { "-q", "-f", @"C:/Users/kartg/OneDrive/Documentos/GitHub/teoriadosjogos/TeoriaDosJogos/Services/fatos.pl" };
            //PlEngine.Initialize(p);
            //var q = new PlQuery("hello(X)");
            string[] p = { "-q" };
            PlEngine.Initialize(p);
            PlQuery.PlCall("consult('C:/Users/kartg/OneDrive/Documentos/GitHub/teoriadosjogos/TeoriaDosJogos/Services/fatos.pl')");

            using (PlQuery q = new PlQuery("hello(X)"))
            {
                foreach (PlQueryVariables v in q.SolutionVariables)
                {
                    var answer = v["X"].ToString();
                    Console.WriteLine(answer);
                }
            }
        }
    }
}