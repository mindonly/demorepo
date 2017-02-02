import java.io.IOException;
import java.util.Scanner;
import java.io.File;

/**
 This program counts the frequencies of all words and symbol sequences in a file.
 */
public class CrossRefGenDemo {

    public static void main(String[] args)
    {
        Scanner in = new Scanner(System.in);
        try
        {
            /*
            System.out.print("Input file: ");
            String inFile = in.next();
            */
            String inFile = "DataAnalyzer.txt";
            Scanner inf = new Scanner(new File(inFile));
            CrossRefGen generator = new CrossRefGen();
            generator.parseText(inf);
            System.out.println("      Identifier " + ": [Lines]");
            generator.displayMap();
            inf.close();
        }
        catch (IOException exception)
        {
            System.out.println("Error: " + exception);
        }
    }
}
