import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.io.FileNotFoundException;
import java.io.PrintWriter;

public class LoanFrame extends JFrame {

    private JButton add, search, edit, list,
                    delete, summary, save, reset;
    private JRadioButton simpLoan, amortLoan;
    private ButtonGroup loanGroup;
    private JComboBox intRatesCombo;
    private JLabel loanTypeLabel, nameLabel, prinLabel,
                   lenLabel, intRatesLabel, titleLabel;
    private JTextArea mainDisplay;
    private JTextField nameInput, prinInput, lenInput;
    private JPanel namePanel, prinPanel, lenPanel, titlePanel,
                   loanTypePanel, displayPanel, loanTermsPanel, actionsPanel;
    private LoanManager loanManager;
    private JScrollPane scrollV;

    public LoanFrame(LoanManager loanManager) {

        this.loanManager = loanManager;
        //this.setSize(640, 480);
        this.setResizable(false);
        this.setTitle("LoanManager");
        this.setLocation(200, 200);
        final int FIELD_WIDTH = 16;

        // CENTER Border
        namePanel = new JPanel();
        namePanel.setLayout(new GridLayout(2, 1));
        nameLabel = new JLabel("1. Borrower Name");
        nameInput = new JTextField("<< Enter Borrower's Name >>", FIELD_WIDTH);
        nameInput.setHorizontalAlignment(JTextField.CENTER);
        nameInput.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) { nameInput.selectAll(); }
            @Override
            public void focusLost(FocusEvent e) { }
        });
        namePanel.add(nameLabel);
        namePanel.add(nameInput);

        prinPanel = new JPanel();
        prinPanel.setLayout(new GridLayout(2, 1));
        prinLabel = new JLabel("2. Principal");
        prinInput = new JTextField("<< Enter Principal Amount >>", FIELD_WIDTH);
        prinInput.setHorizontalAlignment(JTextField.CENTER);
        prinInput.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) { prinInput.selectAll(); }
            @Override
            public void focusLost(FocusEvent e) { }
        });
        prinPanel.add(prinLabel);
        prinPanel.add(prinInput);

        lenPanel = new JPanel();
        lenPanel.setLayout(new GridLayout(2, 1));
        lenLabel = new JLabel("3. Loan Months");
        lenInput = new JTextField("<< Enter Loan Months >>", FIELD_WIDTH);
        lenInput.setHorizontalAlignment(JTextField.CENTER);
        lenInput.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) { lenInput.selectAll(); }
            @Override
            public void focusLost(FocusEvent e) { }
        });
        lenPanel.add(lenLabel);
        lenPanel.add(lenInput);

        loanTermsPanel = new JPanel();
        loanTermsPanel.setLayout(new GridLayout(3, 1, 0, 64));
        loanTermsPanel.add(namePanel);
        loanTermsPanel.add(prinPanel);
        loanTermsPanel.add(lenPanel);

        // WEST Border
        mainDisplay = new JTextArea(16, 24);
        mainDisplay.setWrapStyleWord(true);
        mainDisplay.setLineWrap(true);
        mainDisplay.setEditable(false);

        scrollV = new JScrollPane();
        scrollV.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED);
        scrollV.setBorder(BorderFactory.createTitledBorder("Loan Display"));
        scrollV.setViewportView(mainDisplay);
        displayPanel = new JPanel();
        displayPanel.add(scrollV);

        // SOUTH Border
        loanTypePanel = new JPanel();
        loanTypePanel.setLayout(new FlowLayout(FlowLayout.CENTER, 10, 5));
        simpLoan = new JRadioButton("Simple Loan");
        amortLoan = new JRadioButton("Amortized Loan");
        loanGroup = new ButtonGroup();
        loanGroup.add(simpLoan);
        loanGroup.add(amortLoan);
        simpLoan.setSelected(true);

        loanTypeLabel = new JLabel("4. Loan Type: ");
        intRatesLabel = new JLabel("5. Interest Rate (APY): ");
        intRatesCombo = new JComboBox();
        intRatesCombo.addItem("3 %");
        intRatesCombo.addItem("4 %");
        intRatesCombo.addItem("5 %");
        intRatesCombo.addItem("6 %");
        intRatesCombo.addItem("7 %");
        intRatesCombo.addItem("8 %");

        loanTypePanel.add(loanTypeLabel);
        loanTypePanel.add(simpLoan);
        loanTypePanel.add(amortLoan);
        loanTypePanel.add(intRatesLabel);
        loanTypePanel.add(intRatesCombo);

        // EAST Border
        save = new JButton("Save All Loans");
        delete = new JButton("Delete Loan");
        delete.setEnabled(false);
        edit = new JButton("Edit Loan");
        edit.setEnabled(false);
        summary = new JButton("Loan Summary");
        search = new JButton("Search Loan");
        add = new JButton("Add Loan");
        reset = new JButton("Reset");
        list = new JButton("List Loans");

        actionsPanel = new JPanel();
        actionsPanel.setLayout(new GridLayout(4, 2, 10, 24));
        actionsPanel.add(add);
        actionsPanel.add(save);
        actionsPanel.add(search);
        actionsPanel.add(summary);
        actionsPanel.add(list);
        actionsPanel.add(edit);
        actionsPanel.add(reset);
        actionsPanel.add(delete);

        // NORTH Border
        titlePanel = new JPanel();
        titleLabel = new JLabel("LoanManager: enter items 1-5 and select an action", JLabel.CENTER);
        titlePanel.add(titleLabel);

        // Frame Border Layout
        this.add(displayPanel, BorderLayout.WEST);
        this.add(loanTermsPanel, BorderLayout.CENTER);
        this.add(loanTypePanel, BorderLayout.SOUTH);
        this.add(actionsPanel, BorderLayout.EAST);
        this.add(titlePanel, BorderLayout.NORTH);

        ActionListener listener = new ButtonListener();
        summary.addActionListener(listener);
        add.addActionListener(listener);
        edit.addActionListener(listener);
        search.addActionListener(listener);
        delete.addActionListener(listener);
        list.addActionListener(listener);
        reset.addActionListener(listener);
        save.addActionListener(listener);

        // parse the Loans.txt file, if it exists, and add Loans
        int preLoadLoans = this.loanManager.parseLoanFile();
        if (preLoadLoans > 0)
            mainDisplay.setText("\n" + preLoadLoans + " Loans were found and loaded into LoanManager.");

        this.addWindowListener(new WindowAdapter() {
            @Override
            public void windowOpened(WindowEvent e) { nameInput.requestFocus(); }
        });
    }

    private class ButtonListener implements ActionListener {

        private String borrower;
        private String selectedString;
        private double r;   // annual interest rate / 100 (decimal)
        private double P;   // loan principal
        private int ll;     // loan length
        private Loan addLoan, delLoan;

        public void setLoanParams() {
            borrower = nameInput.getText();
            selectedString = (String) intRatesCombo.getSelectedItem();
            r = Character.getNumericValue(selectedString.charAt(0)) / 100.;

            if (lenInput.getText().isEmpty())
                ll = 0;
            else
                ll = Integer.parseInt(lenInput.getText());

            if (prinInput.getText().isEmpty())
                P = 0;
            else
                P = Double.parseDouble(prinInput.getText());
        }

        public void blankLoanTerms() {
            prinInput.setText("");
            prinInput.setEditable(false);
            lenInput.setText("");
            lenInput.setEditable(false);
        }

        public void openLoanTerms() {
            prinInput.setText("");
            prinInput.setEditable(true);
            lenInput.setText("");
            lenInput.setEditable(true);
        }

        public void resetFields() {
            //nameInput.setText("");
            nameInput.setEditable(true);
            prinInput.setText("");
            prinInput.setEditable(true);
            lenInput.setText("");
            lenInput.setEditable(true);
        }

        public void actionPerformed(ActionEvent event) {
            if (event.getSource() == search) {
                blankLoanTerms();
                setLoanParams();

                int loanIndex = loanManager.findLoan(borrower);
                scrollV.setBorder(BorderFactory.createTitledBorder("Search Result"));

                if (loanIndex == -1)
                    mainDisplay.setText("\nBorrower " + borrower + " not found.");
                else
                    mainDisplay.setText(loanManager.getLoan(loanIndex).toString());

                blankLoanTerms();
                edit.setEnabled(true);
                delete.setEnabled(true);
                resetFields();
                nameInput.requestFocus();
            }
            else if (event.getSource() == edit) {
                nameInput.setEditable(false);
                openLoanTerms();

                add.setText("Replace Loan");
                prinInput.requestFocus();
            }
            else if (event.getSource() == delete) {
                setLoanParams();

                if (simpLoan.isSelected())
                    delLoan = new SimpleLoan(borrower);
                else if (amortLoan.isSelected())
                    delLoan = new AmortizedLoan(borrower);

                Object[] options = {"Cancel", "Delete"};
                Object selectedValue = JOptionPane.showOptionDialog(null,
                        "Are you sure you want to delete the loan?", "Warning",
                        JOptionPane.DEFAULT_OPTION, JOptionPane.WARNING_MESSAGE,
                        null, options, options[0]);
                int choice = (Integer) selectedValue;

                if (choice == 1) {
                    loanManager.del(delLoan);
                    mainDisplay.setText("\n" + "Loan deleted.");
                }
                else mainDisplay.setText("\n" + "Loan NOT deleted.");
                resetFields();
            }
            else if (event.getSource() == list) {
                scrollV.setBorder(BorderFactory.createTitledBorder("Loans List"));
                nameInput.setEditable(true);
                mainDisplay.setText(loanManager.toString());
                edit.setEnabled(false);
                delete.setEnabled(false);
                nameInput.setText("");
                resetFields();
                nameInput.requestFocus();
            }
            else if (event.getSource() == save) {
                String loansFileName = "Loans.txt";
                try (PrintWriter loansFile = new PrintWriter(loansFileName)) {
                    loansFile.println(loanManager.toString());
                    loansFile.close();
                } catch (FileNotFoundException fnf) {
                    System.out.println("FileNotFound: " + loansFileName);
                }
            }
            else if (event.getSource() == reset) {
                nameInput.setText("");
                resetFields();
                nameInput.requestFocus();
            }
            else if (event.getSource() == summary) {
                scrollV.setBorder(BorderFactory.createTitledBorder("Loans Summary"));

                if (loanManager.isEmpty())
                    mainDisplay.setText("No loans to display.");
                else
                    mainDisplay.setText(loanManager.makeSummary());

                if (add.getText().equals("Replace Loan"))
                    add.setText("Add Loan");

                nameInput.requestFocus();
            }
            else if (event.getSource() == add) {
                setLoanParams();

                if (add.getText().equals("Replace Loan"))
                    add.setText("Add Loan");

                if (simpLoan.isSelected())
                    addLoan = new SimpleLoan(borrower, r, ll, P);
                else if (amortLoan.isSelected())
                    addLoan = new AmortizedLoan(borrower, r, ll, P);

                addLoan.process();
                mainDisplay.setText(addLoan.toString());
                loanManager.add(addLoan);
                scrollV.setBorder(BorderFactory.createTitledBorder("Current Loan"));
                edit.setEnabled(true);
                delete.setEnabled(true);
                nameInput.requestFocus();
            }
        }
    }
}
