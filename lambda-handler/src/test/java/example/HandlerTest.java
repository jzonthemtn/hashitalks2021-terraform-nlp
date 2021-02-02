package example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.events.ScheduledEvent;
import org.junit.Test;
import org.mockito.Mockito;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.mockito.Mockito.when;

public class HandlerTest {

    @Test
    public void invokeTest() {

        final ScheduledEvent event = Mockito.mock(ScheduledEvent.class);

        final Context context = Mockito.mock(Context.class);
        when(context.getLogger()).thenReturn(new MockLogger());

        final Handler handler = new Handler();
        handler.handleRequest(event, context);

    }

    public static class MockLogger implements LambdaLogger {

        private static final Logger LOGGER = LoggerFactory.getLogger(MockLogger.class);

        @Override
        public void log(String message) {
            LOGGER.info(message);
        }

        @Override
        public void log(byte[] message) {
            LOGGER.info(new String(message));
        }

    }

}
