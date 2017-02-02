import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.text.DecimalFormat;
import java.util.Arrays;

public class LoanManager {

    private ArrayList<Loan> list;

    public LoanManager() {
        list = new ArrayList<Loan>();
    }

    /**
     * Method isEmpty()
     * @return true if the queue is empty, false otherwise.
     */
    public boolean isEmpty() {
        return list.isEmpty();
    }

    /**
     * Method add() adds a Loan element to the end of the list.
     * @param other   a Loan object.
     */
    public void add(Loan other) {
        if (list.isEmpty()) {
            list.add(other);
            System.out.println("loan added.\n");
            return;
        }
        for (int i = 0; i < list.size(); i++) {
            if (list.get(i).compareTo(other) == 0) {
                this.del(other);
                System.out.println(i + " loan replaced.");
            }
        }
        list.add(other);
        System.out.println("loan added.\n");
    }

    /**
     * Method del() deletes a Loan element from the list.
     * @param other   a Loan object.
     */
    public void del(Loan other) {
       for (int i = 0; i < list.size(); i++) {
           if (list.get(i).compareTo(other) == 0) {
               System.out.println(i + " loan deleted.");
               list.remove(i);
               return;
           }
       }
    }

    /**
     * Method sort() sorts the ArrayList list in place;
     * instead of using Collections.sort(),
     * it uses List.sort() with a lambda expression.
     */
    public void sort() {
        list.sort(Loan::compareTo);
    }

    /**
     Method toString()
     @return a String representation the Loans in the LoadManager list.
     */
    public String toString() {
        String s = "";
        if (list.isEmpty()) System.out.println("\nwatch out, queue is empty!");
        this.sort();
        for (Loan loan : list) {
            s += loan.toString();
            s += "\n";
        }
        return s;
    }

    /**
     * Method findLoan()
     * @param key     the Loan borrower's name, a String.
     * @return the Loan index.
     */
    public int findLoan(String key) {
        int index = 0;
        int found = 0;
        for (int i = 0; i < list.size(); i++) {
            if (list.get(i).name.equals(key)) {
                System.out.println("found a match: " + i + " " + key);
                index = i;
                found = 1;
                break;
            }
        }
        if (found == 0) {
            System.out.println("not found. " + key);
            return -1;
        }
        return index;
    }

    /**
     * Method getLoan()
     * @param index     an index in the LoanManager list, an int.
     * @return the Loan at position index.
     */
    public Loan getLoan(int index) {
        return list.get(index);
    }

    /**
     * Method makeSummary()
     * @return a String representation summarizing the Loans in the list.
     */
    public String makeSummary() {
        String s = "";
        int loanCt = list.size();
        int simpCt = 0;
        int amortCt = 0;
        double totBorrowed = 0;
        DecimalFormat df = new DecimalFormat("#,##0.00");

        for (int i = 0; i < list.size(); i++) {
           totBorrowed += list.get(i).principal;
           if (list.get(i) instanceof SimpleLoan)
               simpCt++;
           else
               amortCt++;
        }

        String ls = System.lineSeparator();
        s += ls + "Loans Report:" + ls;
        s += "-------------" + ls;
        s += "Simple\t" + simpCt + ls;
        s += "Amortized\t" + amortCt + ls;
        s += ls + "Total loans:\t" + loanCt + ls;
        s += "Total borrowed:$ " + df.format(totBorrowed) + ls;

        return s;
    }

    /**
     * Method parseLoanFile() parses a Loans file if it exists.
     * @return the number of loans parsed, an int.
     */
    public int parseLoanFile() {
        int loanCt = 0;
        String loansFile = "Loans.txt";
        File inputFile = new File(loansFile);
        if (inputFile.exists()) {
            try (BufferedReader br = new BufferedReader(new FileReader(inputFile))) {
                String lType = null;
                String lName = null;
                double lPrin = 0;
                double iRate = 0;
                int lMonths = 0;
                for (String line = br.readLine(); line != null; line = br.readLine() ) {
                    String[] tokens = line.split(" ");
                    switch (tokens[0]) {
                        case "Simple":
                        case "Full":
                            lType = tokens[0];
                            break;
                        case "Name:":
                            if (tokens.length > 12) {
                                String[] fullName = Arrays.copyOfRange(tokens, 2, tokens.length);
                                lName = fullName[9] + " " + fullName[10];
                            }
                            else lName = tokens[11];
                            break;
                        case "Principal:":
                            String s1 = tokens[7];
                            String s2 = s1.replaceAll(",", "");
                            lPrin = Double.parseDouble(s2);
                            break;
                        case "Interest":
                            iRate = Double.parseDouble(tokens[3]);
                            break;
                        case "Loan":
                            lMonths = Integer.parseInt(tokens[5]);
                            loadLoan(lType, lName, iRate, lMonths, lPrin);
                            loanCt++;
                            break;
                    }
                }
                br.close();
            } catch (Exception io) {
                System.out.println("some kind of IO exception!");
            }
        }
        return loanCt;
    }

    /**
     * Method loadLoan() pre-loads Loans from a Loans file.
     * @param type  the type of Loan, a String.
     * @param name  the Loan borrower, a String.
     * @param APY   the annual interest rate, a double.
     * @param months    the loan length in months, an int.
     * @param prin  the principal amount borrowed, a double.
     */
    public void loadLoan(String type, String name, double APY, int months, double prin) {
        Loan loan = null;
        double decAPY = APY / 100;

        if (type.equals("Simple")) loan = new SimpleLoan(name, decAPY, months, prin);
        else if (type.equals("Full")) loan = new AmortizedLoan(name, decAPY, months, prin);
        this.add(loan);
        loan.process();
    }
}
