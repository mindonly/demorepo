public class Point {

	private int x;
	private int y;
	
	/**
	 * Initializes a newly created Point object with x and y
	 * coordinates set to 0.
	 */
	public Point() {
		this.x = 0;
		this.y = 0;
	}
	
	/**
	 * Initializes a newly created Point object with the given 
	 * values.
	 * 
	 * @param x the x coordinate of this point
	 * @param y the y coordinate of this point
	 */
	public Point(int x, int y) {
		this.x = x;
		this.y = y;
	}
	
	/**
	 * Initializes a newly created Point object with the values 
	 * from the input string.
	 *
	 * Throws IllegalArgumentException if there are not 2 arguments.
	 * 
	 * @param str string containing values of coordinates
	 */
	public Point(String str) throws IllegalArgumentException {
		String op = str;
		String[] opTokens = op.split(",");
		if (opTokens.length == 2) {
			this.x = Integer.parseInt(opTokens[0]);
			this.y = Integer.parseInt(opTokens[1]);
		}
		else {
            throw new IllegalArgumentException("there must be 2 arguments");
		}
	}
	
	/**
	 * Initializes a newly created Point object with the values 
	 * from the input Point object.
	 * 
	 * @param other a Point object used to initialize this Point 
	 * object
	 */
	public Point(Point other) throws IllegalArgumentException {
		if (other == null) { 
			throw new IllegalArgumentException("argument can't be null");
		}
		
		this.x = other.x;
		this.y = other.y;
	}
	
	/**
	 * Returns the x coordinate of this Point object.
	 * 
	 * @return the x coordinate of this object.
	 */
	public int getX() {
		return this.x;
	}

	/**
	 * Returns the y coordinate of this Point object.
	 * 
	 * @return the y coordinate of this object.
	 */
	public int getY() {
		return this.y;
	}

	/**
	 * Returns a String object that represents this Point as, 
	 * for example, (5, 3) if x is 5 and y is 3.
	 * 
	 * @return a string representation of this Point's value.
	 */
	public String toString() {
		String op = "(" + this.x + "," + this.y + ")";

		return op;
	}
	
	/**
	 * Compares this object to the other object. The result is 
	 * true if and only if the argument is not null and is a 
	 * Point object that contains the same values as this Point 
	 * object.
	 * 
	 * @param obj the object to compare with.
	 * 
	 * @return true if the objects are the same; false 
	 * otherwise.
	 */
	public boolean equals(Object other) {
		if (other == null || !(other instanceof Point))
            return false;

		Point p = (Point) other;
        return this.x == p.x && this.y == p.y;
    }
	
	/**
	 * Returns the Manhattan distance between this Point object 
	 * and the other Point object.
	 * 
	 * Manhattan distance is the distance between two points if
	 * you walk only in a horizontal or vertical direction.
	 * 
	 * @param other the other Point object
	 * 
	 * @return the Manhattan distance between this and other 
	 * Point objects.
	 */
	public int manhattanDistance(Point other) {
		int mdist = this.horiDistance(other) + this.vertDistance(other);
		
		return mdist;
	}
	
	/**
	 * Returns the horizontal distance between the x-coordinate
	 * of this Point object and that of the other Point object.
	 * 
	 * @param other the other Point object
	 * 
	 * @return the horizontal distance between x-coordinates
	 * of this and other Point objects.
	 */
	public int horiDistance(Point other) {
		int hori = 0;
		hori = Math.abs(other.x - this.x);
		
		return hori;
	}
	
	/**
	 * Returns the vertical distance between the y-coordinate
	 * of this Point object and that of the other Point object.
	 * 
	 * @param other the other Point object
	 * 
	 * @return the vertical distance between y-coordinates
	 * of this and other Point objects.
	 */
	public int vertDistance(Point other) {
		int vert = 0;
		vert = Math.abs(other.y - this.y);
				
		return vert;
	}
}