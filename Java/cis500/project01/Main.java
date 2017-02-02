
/**
 * Rob Sanchez
 * CIS 500, Project #1
 * Fall 2016, Tao
 * 2016-09-27
 */

import java.util.Random;

public class Main {

	public static void main(String[] args) {
		int points = 4;
		int lines = 2;
		Random rand = new Random();

		// Point generation
		System.out.printf("\n\nGenerate 4 random Points:\n");
		System.out.printf("------------------------\n");
		Point[] pArray = new Point[points];

		for (int i = 0; i < points; i++) {
			Point p = new Point(rand.nextInt(32) - 16, rand.nextInt(32) - 16);
			pArray[i] = p;
			System.out.println("["+i+"] " + pArray[i]);
		}

		// Point coordinates
		System.out.printf("\nGet each Point's X and Y coordinates:\n");
		System.out.printf("------------------------------------\n");
		System.out.println("[0] " + "X: " + pArray[0].getX() +
									" Y: " + pArray[0].getY());
		System.out.println("[1] " + "X: " + pArray[1].getX() +
									" Y: " + pArray[1].getY());
		System.out.println("[2] " + "X: " + pArray[2].getX() +
									" Y: " + pArray[2].getY());
		System.out.println("[3] " + "X: " + pArray[3].getX() +
									" Y: " + pArray[3].getY());

		// Point equivalence
		System.out.printf("\nAre the Points equivalent?\n");
		System.out.printf("-------------------------\n");
		System.out.printf("Point.equals() reports:\n");
		System.out.println("Points [0] and [1]: " +
							pArray[0].equals(pArray[1]));
		System.out.println("Points [2] and [3]: " +
							pArray[2].equals(pArray[3]));

		// Point horizontal distance
		System.out.printf("\nCalculate horizontal distance:\n");
		System.out.printf("-----------------------------\n");
		System.out.println("Point [0] to [1]: " +
							pArray[0].horiDistance(pArray[1]));
		System.out.println("Point [2] to [3]: " +
							pArray[2].horiDistance(pArray[3]));

		// Point vertical distance
		System.out.printf("\nCalculate vertical distance:\n");
		System.out.printf("---------------------------\n");
		System.out.println("Point [0] to [1]: " +
							pArray[0].vertDistance(pArray[1]));
		System.out.println("Point [2] to [3]: " +
							pArray[2].vertDistance(pArray[3]));

		// Point Manhattan distance
		System.out.printf("\nCalculate Manhattan distance:\n");
		System.out.printf("----------------------------\n");
		System.out.println("Point [0] to Point [1]: " +
							pArray[0].manhattanDistance(pArray[1]));
		System.out.println("Point [2] to Point [3]: " +
							pArray[2].manhattanDistance(pArray[3]));

		// Line creation
		System.out.printf("\nCreate 2 Lines:\n");
		System.out.printf("--------------\n");
		Line[] lArray = new Line[lines];
		int j = 0;
		for (int i = 0; i <= lines; i += 2) {
			Line l = new Line(pArray[i], pArray[i+1]);
			lArray[j] = l;
			System.out.println("["+j+"] " + lArray[j]);
			j++;
		}

		// Line lengths
		System.out.printf("\nCalculate the Line lengths:\n");
		System.out.printf("--------------------------\n");
		int i = 0;
		for (Line item : lArray) {
			System.out.printf("%s %.4f\n", "["+i+"]", item.getDistance());
			i++;
		}

		// Line equivalence
		System.out.printf("\nAre the Lines equivalent?\n");
		System.out.printf("------------------------\n");
		System.out.printf("Line.equals() reports: ");
		System.out.println(lArray[0].equals(lArray[1]));

		// Line parallel
		System.out.printf("\nAre the Lines parallel?\n");
		System.out.printf("----------------------\n");
		System.out.printf("Line.parallelTo() reports: ");
		System.out.println(lArray[0].parallelTo(lArray[1]));

		// Line slopes
		System.out.printf("\nCalculate the Line slopes:\n");
		System.out.printf("-------------------------\n");
		for (Line item : lArray) {
			if (slopeUndef(item)) {
				System.out.printf(item.toString() + ": undefined\n");
			} else {
				System.out.printf("%s: %.4f\n", item.toString(), item.getSlope());
			}
		}

		// Line midpoints
		System.out.printf("\nCalculate the Line midpoints:\n");
		System.out.printf("----------------------------\n");
		for (Line item : lArray) {
			System.out.printf("%s: ", item.toString());
			System.out.println(item.getMidpoint());
		}
	}

	public static boolean slopeUndef(Line l) {
		boolean vert = false;
		try { l.getSlope(); }
		catch(ArithmeticException e) {
			vert = true;
		}

		return vert;
	}
}
