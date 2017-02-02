
public class AmortizedLoan extends Loan {

    public AmortizedLoan(String name) {
        super (name);
    }

    public AmortizedLoan(String name, double rate, int months, double amount) {
        super (name, rate, months, amount);
    }

    /**
     * Calculate the monthly payment according to the correct formula:
     * ( principal * monthly-rate * n ) / (n - 1); where n is (1 + monthly-rate)^length-in-months
     */
    public void calcMonthPayment () {
        double mr = interestRate / 12.;
        double n = Math.pow((1 + mr), length);
        monthlyPayment = (principal * mr * n) / (n - 1);
    }

    public String toString() {
        String ls = System.lineSeparator();
        String s = ls + "Full Amortized Loan" + ls;
        s += super.toString();
        return s;
    }
}