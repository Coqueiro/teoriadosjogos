using System;

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

        public static char[][] StringToGameboard(string gameboard, int[] gameboardLines)
        {
            string[] charsToTrim = { "b(", ",", ")" };
            var gameboardTrim = gameboard;

            foreach (var charToTrim in charsToTrim)
            {
                gameboardTrim = gameboardTrim.Replace(charToTrim, "");
            }

            var gameboardArray = gameboardTrim.ToCharArray();

            var gameboardResult = new char[gameboardLines.Length][];

            var iterator = 0;
            for (iterator = 0; iterator < gameboardLines.Length; iterator++)
            {
                gameboardResult[iterator] = new char[gameboardLines[iterator]];
            }

            iterator = 0;
            for (int iteratorLines = 0; iteratorLines < gameboardLines.Length; iteratorLines++)
            { 
                for (int iteratorColumns = 0; iteratorColumns < gameboardLines[iteratorLines]; iteratorColumns++)
                {
                    gameboardResult[iteratorLines][iteratorColumns] = gameboardArray[iterator++];
                }
            }

            return gameboardResult;
        }
    }
}