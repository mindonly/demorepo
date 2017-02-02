import java.util.*;
import java.io.IOException;

/**
 This program tracks identifiers in a java source code
 file and keeps track of line numbers where each identifier appears.
 */
public class CrossRefGen {
    // declare a reference to Map where the key (word) is a String
    // and the value (a set of line numbers) is a TreeSet of Integer
    Map<String, TreeSet> words;

    public CrossRefGen() {
        // create a TreeMap object that is referenced by 'words'
        this.words = new TreeMap<String, TreeSet>();
    }

    /**
     * Parses java source code and builds the identifier map.
     * @param in the input file (Scanner)
     * @throws IOException if file not found
     */
    public void parseText(Scanner in) throws IOException {
        String token = "";
        int state = 0; // 0 = Space, 1 = LegalWord, 2 = Symbol, 3 = BeginDigit
        int lineNo = 1;

        while (in.hasNextLine()) {
            String line = in.nextLine() + " ";
            if (line.contains("//")) {
                line = line.substring(0, line.indexOf('/')) + " ";
            }
            else if (line.startsWith("//")) {
                line = in.nextLine() + " ";
                lineNo++;
            }
            char[] list = line.toCharArray();

            for ( char ch: list ) {
                // process input text character by character,
                // identify each token and update its count
                switch (state) {
                    case 0:
                        if (ch == ' ') continue;
                        else if (Character.isLetter(ch) || ch == '_') {
                            token += ch;
                            state = 1;
                        }
                            // new token starts with digit
                        else if (Character.isDigit(ch)) {
                            token = "";
                            state = 3; // send to special state 3
                        }
                            // String constant begins
                        else if (ch == '\"') {
                            token = "";
                            state = 4; // send to special state 4
                        }
                        else { state = 2; }
                        break;
                    case 1:
                        if (ch == ' ') {
                            this.updateMap(token, lineNo);
                            token = "";
                            state = 0;
                        }
                        else if (Character.isLetterOrDigit(ch) || ch == '_' ) {
                            token += ch;
                        }
                        else {
                            this.updateMap(token, lineNo);
                            token = Character.toString(ch);
                            state = 2;
                        }
                        break;
                    case 2:
                        if (ch == ' ') {
                            token = "";
                            state = 0;
                        }
                        else if (Character.isLetterOrDigit(ch)) {
                            token = Character.toString(ch);
                            state = 1;
                        }
                            // String constant begins
                        else if (ch == '\"') {
                            token = "";
                            state = 4;  // send to special state 4
                        }
                        break;
                    case 3: // reached only if digit starts new token
                        if (ch == ' ') { state = 0; }
                        break;
                    case 4: // reached only if a String constant begins
                        if (ch == '\"') { state = 0; }
                        break;
                }
                //System.out.println("lineNo: " + lineNo + " token: " + token + " state: " + state);
            }
            lineNo++;
        }
        in.close();
    }

    /**
     * Updates the set of line numbers for aWord (String) found on line aLineNo (Int)
     * @param aWord the set key
     * @param aLineNo the line number to be added
     */
    public void updateMap(String aWord, int aLineNo) {
        TreeSet lineNums = words.get(aWord);
        // if aWord is not in the map, then no set is associated with it
        if (lineNums == null) {
            lineNums = new TreeSet<Integer>();
            words.put(aWord, lineNums);
        }
        // add line number aLineNo to the set lineNums
        lineNums.add(aLineNo);
    }

    /**
     * Returns the set of all map keys (words).
     * @return the Set of all map keys (keySet)
     */
    public Set<String> getWords() {
        return words.keySet();
    }

    /**
     * Returns the set of line numbers for a key (aWord) from the map.
     * @param aWord the map key
     * @return the Set<TreeSet> of all lines associated with a map key (aWord)
     */
    public TreeSet getLines(String aWord) {
        return words.get(aWord);
    }

    /**
     * Displays all mapped identifiers and line numbers on the screen.
     */
    public void displayMap() {
        Set<String> ids = this.getWords();
        System.out.println("      ********************");
        for (String key : ids ) {
            TreeSet lineSet = this.getLines(key);
            System.out.printf("%16s%1s%3s%1s", key, " : ", lineSet, "\n");
        }
    }
}
