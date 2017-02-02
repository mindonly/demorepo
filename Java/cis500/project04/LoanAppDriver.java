import javax.swing.*;

public class LoanAppDriver {

    public static void main(String[] args) {
        LoanManager loanManager = new LoanManager();
        JFrame frame = new LoanFrame(loanManager);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        frame.pack();
        frame.setVisible(true);
    }
}

/* TODO
    1. fix tabs/char display for text file and swing jtextarea
    2. match on partial names for search (ignore case)
    5. optional validation of positive numbers
 */

