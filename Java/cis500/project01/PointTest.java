import static org.junit.Assert.*;

import org.junit.Test;

public class PointTest {

	@Test
	public void testConstructor1() {
		Point p = new Point();

		assertEquals(0, p.getX());
		assertEquals(0, p.getY());
	}
	
	@Test
	public void testConstructor2() {
		Point p = new Point(5,10);

		assertEquals(5, p.getX());
		assertEquals(10, p.getY());
	}

	@Test
	public void testConstructor3() {
		Point p = new Point("5,10");

		assertEquals(5, p.getX());
		assertEquals(10, p.getY());
	}
	
	@Test
	public void testConstructor4() {
		boolean thrown = false;
		
		try { new Point("5"); }
		catch(IllegalArgumentException e) {
			thrown = true;
		}
		assertTrue(thrown);
	}
	
	@Test
	public void testConstructor5() {
		Point p = new Point("5,10");
		Point q = new Point(p);

		assertEquals(5, q.getX());
		assertEquals(10, q.getY());
	}
	
	@Test
	public void testConstructor6() {
		boolean thrown = false;
		Point p = null;
		
		try { new Point(p); }
		catch(IllegalArgumentException e) {
			thrown = true;
		}
		assertTrue(thrown);
	}
	
	@Test
	public void test_toString1() {
		Point p = new Point(5,10);

		assertEquals("(5,10)", p.toString());
	}
	
	@Test
	public void test_toString2() {
		String str = "3,7";
		Point p = new Point(str);

		assertEquals("(3,7)", p.toString());
	}
	
	@Test
	public void test_toString3() {
		Point p = new Point(5,10);
		Point q = new Point(p);

		assertEquals("(5,10)", q.toString());
	}
	
	@Test
	public void testEquals1() {
		Point p = new Point(5,10);

		assertFalse(p.equals(null));
	}
	
	@Test
	public void testEquals2() {
		Point p = new Point(5,10);
		Point q = new Point(5,10);

		assertTrue(p.equals(q));
	}
	
	@Test
	public void testEquals3() {
		Point p = new Point(5,10);
		Point q = new Point(10,5);

		assertFalse(p.equals(q));
	}
	
	@Test
	public void test_manhattanDistance1() {
		Point p = new Point(10,15);

		assertEquals(0, p.manhattanDistance(p));
	}
	
	@Test
	public void test_manhattanDistance2() {
		Point p = new Point(5,7);
		Point q = new Point(10,15);

		assertEquals(13, p.manhattanDistance(q));
	}
	
	@Test
	public void test_manhattanDistance3() {
		Point p = new Point(5,7);
		Point q = new Point(0,0);

		assertEquals(12, p.manhattanDistance(q));
	}
	
	@Test
	public void test_manhattanDistance4() {
		Point p = new Point(5,7);
		Point q = new Point(0,-5);

		assertEquals(17, p.manhattanDistance(q));
	}
	
	@Test
	public void test_manhattanDistance5() {
		Point a = new Point(0,-50);
		Point b = new Point(-50,0);

		assertEquals(100, a.manhattanDistance(b));
		assertEquals(100, b.manhattanDistance(a));
	}

	@Test
	public void test_manhattanDistance6() {
		Point a = new Point(1,10);
		Point b = new Point(-1,10);

		assertEquals(2, a.manhattanDistance(b));
		assertEquals(2, b.manhattanDistance(a));
	}
	
	@Test
	public void test_horiDistance() {
		Point p = new Point(0,0);
		Point q = new Point(3,4);

		assertEquals(3, p.horiDistance(q));
	}
	
	@Test
	public void test_vertDistance() {
		Point p = new Point(0,0);
		Point q = new Point(3,4);

		assertEquals(4, p.vertDistance(q));
	}
}
