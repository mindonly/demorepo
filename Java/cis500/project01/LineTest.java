import static org.junit.Assert.*;

import org.junit.Ignore;
import org.junit.Test;

public class LineTest {

	@Test
	// construct with 4 coordinates
	public void testConstructor1() {
		Line l = new Line(-9,-2,-7,2);

		assertEquals("[(-9,-2),(-7,2)]", l.toString());
	}

	@Test
	// construct with 2 Points
	public void testConstructor2() {
		Point a = new Point(2,4);
		Point b = new Point(-3,-2);
		Line l = new Line(a,b);

		assertEquals("[(2,4),(-3,-2)]", l.toString());
	}

	@Test
	// construct with 2nd Point null
	public void testConstructor3() {
		boolean thrown = false;

		Point a = new Point(2,4);
		Point b = null;

		try { new Line(a,b); }
		catch(IllegalArgumentException e) {
			thrown = true;
		}
		assertTrue(thrown);
	}

	@Test
	// same point
	public void testConstructor4() {
		Point a = new Point(0,0);
		Point b = new Point(0,0);
		Line l = new Line(a,b);

		assertEquals("[(0,0),(0,0)]", l.toString());
	}

	@Test
	// 4 coordinates, positive slope
	public void test_getSlope1() {
		Line l = new Line(9,3,6,-2);

		assertEquals(1.6667, l.getSlope(), 0.0001);
	}

	@Test
	// 2 Points, positive slope
	public void test_getSlope2() {
		Point a = new Point(6,-2);
		Point b = new Point(9,3);
		Line l = new Line(a,b);

		assertTrue(l.getSlope() > 0);
		assertEquals(1.6667, l.getSlope(), 0.0001);
	}

	@Test
	// 2 Points, negative slope
	public void test_getSlope3() {
		Point a = new Point(-2,-5);
		Point b = new Point(2,-9);
		Line l = new Line(a,b);

		assertTrue(l.getSlope() < 0);
		assertEquals(-1, l.getSlope(), 0.0);
	}

	@Test
	// 2 Points, slope == 0
	public void test_getSlope4() {
		Point a = new Point(4,3);
		Point b = new Point(9,3);
		Line l = new Line(a,b);

		assertEquals(0, l.getSlope(), 0.0);
	}

	@Test
	// 2 Points, slope undefined (vertical line)
	public void test_getSlope5() {
		boolean thrown = false;

		Point a = new Point(3,-1);
		Point b = new Point(3,5);
		Line l = new Line(a,b);

		try { l.getSlope(); }
		catch(ArithmeticException e) {
			thrown = true;
		}
		assertTrue(thrown);
	}

	@Test
	// 4 coordinates
	public void test_getDistance1() {
		Line l = new Line(0,0,3,4);

		assertEquals(5, l.getDistance(), 0.1);
	}

	@Test
	// 2 Points
	public void test_getDistance2() {
		Point a = new Point(3,4);
		Point b = new Point(0,0);
		Line l = new Line(a,b);

		assertEquals(5, l.getDistance(), 0.0);
	}

	@Test
	// 4 coordinates, result type double
	public void test_getDistance3() {
		Line l = new Line(6,-2,9,3);

		assertEquals(5.8310, l.getDistance(), 0.0001);
	}

	@Test
	// 2 Points, result type double
	public void test_getDistance4() {
		Point a = new Point(9,3);
		Point b = new Point(6,-2);
		Line l = new Line(a,b);

		assertEquals(5.8310, l.getDistance(), 0.0001);
	}

	@Test
	// slope == 0, horizontal line
	public void test_getMidpoint1() {
		Point a = new Point(2,1);
		Point b = new Point(6,1);
		Line l = new Line(a,b);
		Point mid = l.getMidpoint();

		assertEquals("(4,1)", mid.toString());
	}

	@Test
	// undefined slope, vertical line
	public void test_getMidpoint2() {
		Point a = new Point(4,-3);
		Point b = new Point(4,3);
		Point mid = new Point(4,0);
		Line l = new Line(a,b);

		assertTrue(mid.equals(l.getMidpoint()));
	}

	@Test
	// positive slope
	public void test_getMidpoint3() {
		Point a = new Point(1,1);
		Point b = new Point(5,5);
		Line l = new Line(a,b);
		Point mid = l.getMidpoint();
		Point threethree = new Point (3,3);

		assertEquals("(3,3)", mid.toString());
		assertTrue(mid.equals(threethree));
	}

	@Test
	// negative slope, same line different directions
	public void test_getMidpoint4() {
		Point a = new Point(-3,4);
		Point b = new Point(2,1);
		Line l = new Line(a,b);
		Line m = new Line(b,a);

		assertEquals(l.getMidpoint(), m.getMidpoint());
	}

	@Test
	// null obj
    public void testEquals1() {
    	boolean thrown = false;

		Point a = new Point(2,1);
		Point b = new Point(3,5);
		Line l = new Line(a,b);
		Line m = null;

		try { l.equals(m); }
		catch(IllegalArgumentException e) {
			thrown = true;
		}

		assertTrue(thrown);
    }

    @Test
	// wrong object type (Point vs. Line)
	public void testEquals2() {
		boolean thrown = false;

		Point a = new Point(2,1);
		Point b = new Point(3,5);
		Line l = new Line(a,b);

		try { l.equals(a); }
		catch(IllegalArgumentException e) {
			thrown = true;
		}

		assertTrue(thrown);
	}

	@Test
	// same points, different directions
	public void testEquals3() {
		Point a = new Point(2,1);
		Point b = new Point(3,5);
		Line l = new Line(a,b);
		Line m = new Line(b,a);

		assertFalse(l.equals(m));
	}

	@Test
	// difference in slopes > 0.05
	public void test_parallelTo1() {
		Point a = new Point(-2,-4);
		Point b = new Point(5,2);
		Point c = new Point(0,-4);
		Point d = new Point(7,-1);

		Line l = new Line(a,b);
		Line m = new Line(c,d);

		assertFalse(l.parallelTo(m));
	}

	@Test
	// difference in slopes < 0.05
	public void test_parallelTo2() {
		Point a = new Point(-2,-4);
		Point b = new Point(5,2);
		Point c = new Point(0,-4);
		Point d = new Point(9,4);

		Line l = new Line(a,b);
		Line m = new Line(c,d);

		assertTrue(l.parallelTo(m));
	}

	@Test
	// 2 vertical lines
	public void test_parallelTo3() {
		Point a = new Point(-6,-1);
		Point b = new Point(-6,2);
		Point c = new Point(-5,-2);
		Point d = new Point(-5,2);

		Line l = new Line(a,b);
		Line m = new Line(c,d);

		assertTrue(l.parallelTo(m));
	}

	@Test
	// 1 vertical line, 1 not
	public void test_parallelTo4() {
		Point a = new Point(-6,-1);
		Point b = new Point(-6,2);
		Point c = new Point(-5,-2);
		Point d = new Point(-1,3);

		Line l = new Line(c,d);
		Line m = new Line(a,b);

		assertFalse(l.parallelTo(m));
	}
}
