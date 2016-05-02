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
            ////Environment.SetEnvironmentVariable("SWI_HOME_DIR", @"C:\Program Files (x86)\swipl\boot64.prc");
            Environment.SetEnvironmentVariable("Path", @"C:\Users\kartg\OneDrive\Documentos\swipl");
            Environment.SetEnvironmentVariable("Path", @"C:\Users\kartg\OneDrive\Documentos\swipl\bin");
            ////Environment.SetEnvironmentVariable("Path", @"C\Program Files (x86)\swipl\boot");
            //string[] p = { "-q", "-f", @"C:\Program Files (x86)\swipl\fatos.pl" };
            ////string[] p = { "-q", "-f", @"fatos.pl" };
            //PlEngine.Initialize(p);
            //var q = new PlQuery("viado(X)");
            //Console.WriteLine(q);

            string[] p = { "-q" };
            PlEngine.Initialize(p);
            //get my Objects

            PlQuery.PlCall("consult('C:/Users/kartg/OneDrive/Documentos/GitHub/teoriadosjogos/TeoriaDosJogos/Services/fatos.pl')"); //HERE IS THE CHANGE

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