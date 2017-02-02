import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

/**
 This class encrypts files using the Caesar cipher.
 */
public class Cipher {

    private String key;
    private char[] map;

    /**
     Constructs a cipher object with a given key.
     @param aKey the encryption key
     */
    public Cipher(String aKey) {
        this.key = aKey;
        this.map = new char[26];
        this.InitMap();
    }

    /**
     Encrypts the contents of a stream.
     @param in the input stream
     @param out the output stream
     */
    public void encryptStream(InputStream in, OutputStream out)
            throws IOException {
        boolean done = false;
        while (!done) {
            int next = in.read();
            if (next == -1) done = true;
            else {
                char b = (char) next;
                char c = encrypt(b);
                out.write(c);
            }
        }
    }

    /**
     Decrypts the contents of a stream.
     @param in the input stream
     @param out the output stream
     */
    public void decryptStream(InputStream in, OutputStream out)
            throws IOException {
        boolean done = false;
        while (!done) {
            int next = in.read();
            if (next == -1) done = true;
            else {
                char b = (char) next;
                char c = decrypt(b);
                out.write(c);
            }
        }
    }

    /**
     Encrypts a char.
     @param c the char to encrypt
     @return the encrypted char
     */
    public char encrypt(char c) {
        if (Character.isUpperCase(c)) {
            c = this.map[c - 'A'];
        }
        if (Character.isLowerCase(c)) {
            c = Character.toUpperCase(c);
            c = this.map[c - 'A'];
            c = Character.toLowerCase(c);
        }

        return c;
    }

    /**
     Decrypts a char.
     @param c the char to decrypt
     @return the decrypted char
     */
    public char decrypt(char c) {
        if (Character.isUpperCase(c)) {
            int i = this.getMapIndex(c);
            c = (char) ('A' + i);
        }
        if (Character.isLowerCase(c)) {
            c = Character.toUpperCase(c);
            int i = this.getMapIndex(c);
            c = (char) ('A' + i);
            c = Character.toLowerCase(c);
        }

        return c;
    }

    /**
     Check and see if letter c can be found among the first
     num elements of array map.
     @param c  the target letter
     @param num  the number of elements to search
     Return true if c is found, otherwise false.
     */
    public boolean foundInMap(char c, int num) {
        for (int i = 0; i < num; i++) {
            if (c == this.map[i]) return true;
        }

        return false;
    }

    /**
     Return the index of letter c in array map.
     @param c the target letter
     @return i the index
     Return -1 if not found
     */
    public int getMapIndex(char c) {
        int num = this.map.length;
        for (int i = 0; i < num; i++) {
            if (c == this.map[i]) return i;
        }

        return -1;
    }

    /**
     Initialize array map, first with letters in instance variable
     key then with letters 'Z' through 'A'. Note that there
     are no duplicate letters in map; that is, ignore the letter
     under consideration if it is already in the array.
     */
    public void InitMap() {
        int pos = 0;         // position where the next letter is stored

        // loop through each letter in instance variable
        // key and store it in array map if it is not there
        for (int i = 0; i < this.key.length(); i++) {
            char c = this.key.charAt(i);
            if (Character.isLowerCase(c))
                c = Character.toUpperCase(c);
            if (!(this.foundInMap(c, this.map.length))) {
                this.map[pos] = c;
                pos++;
            }
        }

        // loop through each letter from 'Z' to 'A' and store
        // it in array map if it is not there already
        char c = 'Z';
        while (pos < this.map.length) {
            if (!(this.foundInMap(c, this.map.length))) {
                this.map[pos] = c;
                pos++;
            }
            c--;
        }
    }

    /**
     Return a string representation of an object of this class
     @Override
     */
    public String toString() {
        int i;
        String s = key + "\n";
        s += "\n";
        for (i = 0; i < map.length; i++)
            s += map[i] + " ";
        s += "\n";
        for (i = 0; i < map.length; i++)
            s += i%10 + " ";

        return s;
    }
}
