import static org.junit.Assert.*;
import org.junit.Ignore;
import org.junit.Test;
import java.util.Random;

/**
 * This class is used to test the CrossRefGen class with Junit.
 */
public class CrossRefGenTest {

    @Test
    public void testUpdateMap() {
        CrossRefGen gen = new CrossRefGen();
        Random rand = new Random();

        for (int i = 0; i < 5; i++) {
            gen.updateMap("Hockey", rand.nextInt(999));
            gen.updateMap("Baseball", rand.nextInt(999));
            gen.updateMap("Basketball", rand.nextInt(999));
            gen.updateMap("Football", rand.nextInt(999));
        }
        gen.displayMap();
    }

}
