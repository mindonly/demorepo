import static org.junit.Assert.*;
import org.junit.Ignore;
import org.junit.Test;


/**
 This class is used to test the Cipher class with JUnit.
 */
public class CipherTest {

    @Test
    // key String variable
    public void testConstructor1() {
        String key = "curveball";
        Cipher ciph = new Cipher(key);

        String cipherString = ciph.toString();
        assertEquals(key, cipherString.substring(0, key.length()));
        System.out.println("\ntestConstructor1():");
        System.out.println(ciph);
    }

    @Test
    // raw String in constructor call
    public void testConstructor2() {
        Cipher ciph = new Cipher("slider");

        String cipherString = ciph.toString();
        assertEquals("slider", cipherString.substring(0, "slider".length()));
    }

    @Test
    // mixed-case key
    public void testConstructor3() {
        String key = "mIxEdCaSe";
        Cipher ciph = new Cipher(key);

        String cipherString = ciph.toString();
        assertEquals(key, cipherString.substring(0, key.length()));
        System.out.println("\ntestConstructor3():");
        System.out.println(ciph);
    }

    @Test
    // find key char in Cipher.map
    public void testFoundInMap1() {
        String key = "TestKey";
        Cipher ciph = new Cipher(key);

        boolean found = false;
        char c = 'T';
        found = ciph.foundInMap(c, 26);
        assertTrue(found);
    }

    @Test
    // find non-key char in Cipher.map
    public void testFoundInMap2() {
        String key = "TestKey";
        Cipher ciph = new Cipher(key);

        boolean found = false;
        char c = 'Q';
        found = ciph.foundInMap(c, 26);
        assertTrue(found);
    }

    @Test
    // find key char in Cipher.map at expected position
    public void testGetMapIndex1() {
        String key = "TestKey";
        Cipher ciph = new Cipher(key);

        char c = 'K';
        int i = ciph.getMapIndex(c);
        assertEquals(i, 3);
    }

    @Test
    // find non-key char in Cipher.map at expected position
    public void testGetMapIndex2() {
        String key = "TestKey";
        Cipher ciph = new Cipher(key);

        char c = 'Z';
        int i = ciph.getMapIndex(c);
        assertEquals(i, 5);
        System.out.println("\ntestGetMapIndex2():");
        System.out.println(ciph);
    }

    @Test
    // encrypt/decrypt a short phrase
    public void testEncryptDecrypt1() {
        String key = "homerun";
        Cipher ciph = new Cipher(key);
        String phrase = "Take me out to the ballgame!";
        char[] cipherText = new char[phrase.length()];

        for (int i = 0; i < cipherText.length; i++) {
            cipherText[i] = ciph.encrypt(phrase.charAt(i));
            assertEquals(phrase.charAt(i), ciph.decrypt(cipherText[i]));
        }
    }

    @Test
    // encrypt/decrypt a short phrase
    public void testEncryptDecrypt2() {
        String key = "touchdown";
        Cipher ciph = new Cipher(key);
        String phrase = "It's going, it's going, it's gone!";
        char[] cipherText = new char[phrase.length()];

        for (int i = 0; i < cipherText.length; i++) {
            cipherText[i] = ciph.encrypt(phrase.charAt(i));
            assertEquals(ciph.encrypt(phrase.charAt(i)), cipherText[i]);
        }
    }
`}
