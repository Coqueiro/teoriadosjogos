using System;
using TeoriaDosJogos.Models;

namespace TeoriaDosJogos.Services
{
    public static class PrologUtils
    {
        public static string GameboardToString(string[][] gameboard)
        {
            var resultString = "";

            foreach (var line in gameboard)
            {
                resultString += String.Join(",", line);
                resultString += ",";
            }

            return resultString.Substring(0, resultString.Length - 1);
        }

        public static char[][] StringToGameboard(string gameboard)
        {
            string[] charsToTrim = { "b", ",", "(", ")" };
            var gameboardTrim = gameboard;

            foreach (var charToTrim in charsToTrim)
            {
                gameboardTrim = gameboardTrim.Replace(charToTrim, "");
            }

            var gameboardArray = gameboardTrim.ToCharArray();
            var numberOfLines = 8;
            var numberOfColumns = 8;
            var gameboardResult = new char[numberOfLines][];

            for (int iterator = 0; iterator < gameboardResult.Length; iterator++)
            {
                gameboardResult[iterator] = new char[numberOfColumns];
            }

            for(int iterator = 0; iterator < gameboardArray.Length; iterator++)
            {
                gameboardResult[iterator / numberOfLines][iterator % 8] = gameboardArray[iterator];
            }

            return gameboardResult;
        }
    }
}