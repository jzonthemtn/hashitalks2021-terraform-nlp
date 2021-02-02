package example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.events.ScheduledEvent;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.junit.Test;
import org.mockito.Mockito;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HandlerTest {

    private static final Logger logger = LoggerFactory.getLogger(HandlerTest.class);

    private final Gson gson = new GsonBuilder()
            .setPrettyPrinting()
            .create();

    @Test
    public void invokeTest() {

        final ScheduledEvent event = Mockito.mock(ScheduledEvent.class);
        final Context context = new TestContext();

        final Handler handler = new Handler();
        final String result = handler.handleRequest(event, context);

    }

}
