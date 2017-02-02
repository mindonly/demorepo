import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.InputMismatchException;
import java.util.Scanner;

/**
 This program encrypts a file, using the Caesar cipher.
 */
public class Main {

    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);

        System.out.println("\n[1] Encrypt ");
        System.out.println("[2] Decrypt ");
        System.out.println("Please make a selection: ");

        int choice = 0;

        try {
            choice = in.nextInt();
        }
        catch (InputMismatchException ime) {
            String input = in.next();
            char c = input.charAt(0);
            if ( c == 'e' || c == 'E' ) choice = 1;
            if ( c == 'd' || c == 'D' ) choice = 2;
        }

        String inFile, outFile;

        try {

            switch (choice) {
                case 1:
                    System.out.println("You chose ENCRYPT");
                    //inFile  = "/tmp/data.txt";
                    inFile  = "C:\\windows\\temp\\data.txt";
                    //outFile = "/tmp/data.txt.enc";
                    outFile = "C:\\windows\\temp\\data.txt.enc";
                    break;

                case 2:
                    System.out.println("You chose DECRYPT");
                    //inFile  = "/tmp/data.txt.enc";
                    inFile  = "C:\\windows\\temp\\data.txt.enc";
                    //outFile = "/tmp/data.txt.dec";
                    outFile = "C:\\windows\\temp\\data.txt.dec";
                    break;

                default:
                    System.out.println("Sorry, invalid choice.");
                    return;
            }

            System.out.println("\nThe input file will be: " + inFile);
            System.out.println("The output file will be: " + outFile);
            System.out.println("\nEncryption key: ");
            String key = in.next();

            InputStream inStream = new FileInputStream(inFile);
            OutputStream outStream = new FileOutputStream(outFile);

            Cipher cipher = new Cipher(key);
            System.out.println(cipher);

            if (choice == 1) {
                cipher.encryptStream(inStream, outStream);
                System.out.println("\nplaintext:  " + inFile);
                System.out.println("ciphertext: " + outFile);
            } else {
                cipher.decryptStream(inStream, outStream);
                System.out.println("\nciphertext: " + inFile);
                System.out.println("plaintext:  " + outFile);
            }

            inStream.close();
            outStream.close();
        }
        catch (IOException exception) {
            System.out.println("Error processing file: " + exception);
        }
    }
}
