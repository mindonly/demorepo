public class Line {

	private Point p1, p2;

	/**
	 * Initializes a newly created Line object with the given 
	 * values
	 * 
	 * @param x1 and x2 the x coordinates of p1 and p2 
	 * @param y1 and y2 the y coordinates of p1 and p2.
	 */
	public Line(double x1, double y1, double x2, double y2) {
		int xA = (int) x1;
		int xB = (int) x2;
		int yA = (int) y1;
		int yB = (int) y2;
		
		this.p1 = new Point(xA, yA);
		this.p2 = new Point(xB, yB);
	}

	/**
	 * Initializes a newly created Line object with the values 
	 * from the two input Point objects
	 * 
	 * @param p1 and p2 two Point objects used to initialize 
	 * this Line object.
	 */
	public Line(Point p1, Point p2) throws IllegalArgumentException {
		if ( (p1 == null) || (p2 == null) ) {
			throw new IllegalArgumentException("argument can't be null");
		}
		this.p1 = p1;
		this.p2 = p2;
	}

	/**
	 * Calculate the slope of this Line object using the  
	 * formula (y1 - y2)/(x1 - x2)
	 * 
	 * slope of a vertical line is undefined, that is, x1 and x2  
	 * are equal, throw an ArithmeticException 
	 *  
	 * @return the slope of this Line object.
	 */
	public double getSlope() throws ArithmeticException {
		if (this.p1.getX() == this.p2.getX()) {
			throw new ArithmeticException("vertical slope is undefined");
		}

		double slope = 0;
		double num = (this.p1.getY() - this.p2.getY());

		if (num == 0) return slope;

		double den = (this.p1.getX() - this.p2.getX());
		slope = num/den;

		return slope;
	}

	/**
	 * Calculate the distance between the two points of 
	 * this Line object
	 * 
	 * @return the distance.
	 */
	public double getDistance() {
		double hori = (double) this.p1.horiDistance(p2);
		double vert = (double) this.p1.vertDistance(p2);

		// pythagorean theorem
		double distance = Math.sqrt(Math.pow(hori, 2) + Math.pow(vert, 2));
		
		return distance;
	}

	/**
	 * Calculate the middle point of this Line object
	 *
	 * @return a Point object.
	 */
	public Point getMidpoint() {
		int midh = this.p1.horiDistance(p2) / 2;
		int midv = this.p1.vertDistance(p2) / 2;
		int nx = 0; int ny = 0;

		// undefined slope, vertical line
		try { this.getSlope(); }
		catch(ArithmeticException e) {
			if (this.p1.getY() < this.p2.getY()) {
				nx = this.p1.getX();
				ny = this.p1.getY() + midv;
			} else if (this.p2.getY() < this.p1.getY()) {
				nx = this.p2.getX();
				ny = this.p2.getY() + midv;
			}
			Point mid = new Point(nx, ny);

			return mid;
		}

		if (this.getSlope() == 0) {
			// slope == 0, horizontal line
			if (this.p1.getX() < this.p2.getX()) {
				nx = this.p1.getX() + midh;
				ny = this.p1.getY();
			} else if (this.p2.getX() < this.p1.getX()) {
				nx = this.p2.getX() + midh;
				ny = this.p2.getY();
			}
		} else if (this.getSlope() > 0) {
			// slope > 0, upward-sloping
			if (this.p1.getY() < this.p2.getY()) {
				nx = this.p1.getX() + midh;
				ny = this.p1.getY() + midv;
			} else if (this.p2.getY() < this.p1.getY()) {
				nx = this.p2.getX() + midh;
				ny = this.p2.getY() + midv;
			}
		} else if (this.getSlope() < 0) {
			// slope < 0, downward-sloping
			if (this.p1.getY() > this.p2.getY()) {
				nx = this.p1.getX() + midh;
				ny = this.p1.getY() - midv;
			} else if (this.p2.getY() > this.p1.getY()) {
				nx = this.p2.getX() + midh;
				ny = this.p2.getY() - midv;
			}
		}
		Point mid = new Point(nx, ny);

		return mid;
	}
	
	/**
	 * Two lines are parallel if they have the same slope, or 
	 * if they are both vertical. Note that two slopes are the 
	 * same if their difference is very small
	 *
	 * @param line the other Line object
	 *
	 * @return true if the objects are parallel; false
	 * otherwise.  
	 */ 
	public boolean parallelTo(Line line) {
		boolean this_undef = false;
		boolean line_undef = false;

		try { this.getSlope(); }
		catch(ArithmeticException e) {
			this_undef = true;
		}
		try { line.getSlope(); }
		catch(ArithmeticException f) {
			line_undef = true;
		}

		if (this_undef && line_undef)
			return true;
		else if (this_undef || line_undef)
			return false;

		return Math.abs(this.getSlope() - line.getSlope()) < 0.05;
	}

	/**
	 * Compares this object to the other object. The result is 
	 * true if and only if the argument is not null and is a 
	 * Line object with the same values as this Line object
	 * 
	 * @param obj the object to compare with.
	 * 
	 * @return true if the objects are the same; false 
	 * otherwise.
	 */
	public boolean equals(Object obj) throws IllegalArgumentException {
		if (obj == null || !(obj instanceof Line) ) {
			throw new IllegalArgumentException("argument can't be null or must be a Line object");
		}
		Line l = (Line) obj;

		return this.p1.equals(l.p1) && this.p2.equals(l.p2);
	}
	
	/**
	 * Returns a String object that represents this Line 
	 * 
	 * @return a string representation of this Line's value.
	 */
	public String toString() {
		return "[" + p1 + "," + p2 +"]";
	}
}
