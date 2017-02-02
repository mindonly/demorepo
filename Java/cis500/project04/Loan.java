import java.text.DecimalFormat;

public abstract class Loan implements Comparable<Loan> {
    protected String name;                      // the applicant's name
    protected double interestRate;              // the annual interest rate
    protected int length;                       // the length of the loan in months
    protected double principal;                 // the principal
    protected double monthlyPayment;            // the monthly payment

    public Loan(String name) {
        this.name = name;
        this.interestRate = 0;
        this.length = 0;
        this.principal = 0;
    }

    public Loan(String name, double rate, int months, double amount) {
        this.name = name;
        this.interestRate = rate;
        this.length = months;
        this.principal = amount;
    }

    /**
     * Method process() calls the subclass method to calculate
     * the Loan monthly payment.
     */
    public void process() {
        this.calcMonthPayment();
    }

    public String toString() {
        String ls = System.lineSeparator();
        DecimalFormat df = new DecimalFormat("#,##0.00");
        String s = "Name:           " + name + ls;
        s += "Principal:      $ " + df.format(principal) + ls;
        s += "Interest Rate:  " + df.format(interestRate * 100) + " %" + ls;
        s += "Loan Length:    " + length + " months" + ls;
        s += "Payment:        $ " + df.format(monthlyPayment) + ls;
        return s;
    }

    /**
     * Compares one Loan with another based on name,
     * this implements the Comparable interface for Loan.
     * @param other     a Loan object.
     * @return 0 if they are the same, -1 or 1 otherwise.
     */
    public int compareTo(Loan other) {
        if (this.name.compareTo(other.name) < 0 ) return -1;
        if (this.name.compareTo(other.name) > 0 ) return 1;
        return 0;
    }

    abstract public void calcMonthPayment();    // an abstract method
}
