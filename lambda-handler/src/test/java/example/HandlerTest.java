package example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.events.ScheduledEvent;
import org.junit.Test;
import org.mockito.Mockito;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.mockito.Mockito.when;

public class HandlerTest {

    private static final Logger LOGGER = LoggerFactory.getLogger(HandlerTest.class);

    @Test
    public void invokeTest() {

        final ScheduledEvent event = Mockito.mock(ScheduledEvent.class);

        final Context context = Mockito.mock(Context.class);
        when(context.getLogger()).thenReturn(new TestLogger());

        final Handler handler = new Handler();
        final String result = handler.handleRequest(event, context);

    }

}
