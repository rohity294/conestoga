import io.micrometer.core.instrument.Gauge;
import io.micrometer.prometheus.PrometheusMeterRegistry;
import java.util.Random;
import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import java.io.OutputStream;
import java.net.InetSocketAddress;

public class TelemetryExample {
    public static void main(String[] args) throws Exception {
        PrometheusMeterRegistry registry = new PrometheusMeterRegistry(io.micrometer.prometheus.PrometheusConfig.DEFAULT);
        Random random = new Random();

        // Use a mutable holder for the temperature
        Double[] temperature = new Double[] {20.0};

        // Register a gauge that reads from the temperature[0] value
        Gauge.builder("temperature_celsius", temperature, t -> t[0])
             .description("Temperature in Celsius")
             .register(registry);

        // Start HTTP server on port 8080
        HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);
        server.createContext("/metrics", new HttpHandler() {
            @Override
            public void handle(HttpExchange exchange) {
                try {
                    String response = registry.scrape();
                    exchange.getResponseHeaders().set("Content-Type", "text/plain; version=0.0.4");
                    exchange.sendResponseHeaders(200, response.length());
                    OutputStream os = exchange.getResponseBody();
                    os.write(response.getBytes());
                    os.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
        server.setExecutor(null);
        server.start();

        System.out.println("Metrics server running at http://localhost:8080/metrics");

        // Update temperature every 5 seconds
        while (true) {
            temperature[0] = 20 + random.nextDouble() * 10; // between 20 and 30
            Thread.sleep(5000);
        }
    }
}
