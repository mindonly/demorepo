
public class SimpleLoan extends Loan {

    public SimpleLoan(String name) {
        super (name);
    }

    public SimpleLoan(String name, double rate, int months, double amount) {
        super (name, rate, months, amount);
    }

    /**
     * Calculate the monthly payment according to the correct formula:
     * ( principal * (monthly-rate * length-in-months + 1) ) / length-in-months
     */
    public void calcMonthPayment () {
        double mr = interestRate / 12.;
        monthlyPayment = (principal * (mr * length + 1)) / length;
    }

    public String toString() {
        String ls = System.lineSeparator();
        String s = ls + "Simple Interest Loan" + ls;
        s += super.toString();
        return s;
    }
}