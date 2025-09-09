import io.micrometer.core.instrument.Gauge;
import io.micrometer.prometheus.PrometheusMeterRegistry;
import io.micrometer.prometheus.PrometheusConfig;
import java.util.Random;
import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import java.io.OutputStream;
import java.net.InetSocketAddress;

public class TelemetryExample {
    public static void main(String[] args) throws Exception {
        // Create Prometheus registry
        PrometheusMeterRegistry registry = new PrometheusMeterRegistry(PrometheusConfig.DEFAULT);

        // Temperature holder (mutable)
        Double[] temperature = new Double[]{20.0};

        // Register temperature gauge
        Gauge.builder("temperature_celsius", temperature, t -> t[0])
            .description("Temperature in Celsius")
            .register(registry);

        // Start HTTP server on 0.0.0.0:8080 (to allow external scraping too)
        System.out.println("Starting HTTP server...");
        HttpServer server = HttpServer.create(new InetSocketAddress("0.0.0.0", 8080), 0);
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
        server.setExecutor(null); // default executor
        server.start();
        System.out.println("Metrics server running at http://localhost:8080/metrics");

        // Random temperature generator
        Random random = new Random();

        // Update the temperature value every 5 seconds
        while (true) {
            double newTemp = 20 + random.nextDouble() * 10; // 20–30°C
            temperature[0] = newTemp;
            System.out.println("Updated temperature: " + newTemp);
            Thread.sleep(5000);
        }
    }
}
