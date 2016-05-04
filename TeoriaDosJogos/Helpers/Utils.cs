namespace TeoriaDosJogos.Helpers
{
    public static class Utils
    {
        public static int[] LengthArray(string[][] gameboard)
        {
            var lengthArray = new int[gameboard.Length];
            for(var iterator = 0; iterator < gameboard.Length; iterator++)
            {
                lengthArray[iterator] = gameboard[iterator].Length;
            }

            return lengthArray;
        }
    }    
}