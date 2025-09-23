'use strict';

const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');

const { MeterProvider } = require('@opentelemetry/sdk-metrics');
const { OTLPMetricExporter } = require('@opentelemetry/exporter-metrics-otlp-http');

const { LoggerProvider, SimpleLogRecordProcessor } = require('@opentelemetry/sdk-logs');
const { OTLPLogExporter } = require('@opentelemetry/exporter-logs-otlp-http');

// ---- Tracing ----
const traceExporter = new OTLPTraceExporter({
  url: 'http://localhost:4318/v1/traces'
});

const sdk = new NodeSDK({
  traceExporter,
  instrumentations: [getNodeAutoInstrumentations()],
});

// ---- Metrics ----
const metricExporter = new OTLPMetricExporter({
  url: 'http://localhost:4318/v1/metrics'
});

const meterProvider = new MeterProvider();
const meter = meterProvider.getMeter('monolith-app');

const requestCounter = meter.createCounter('http_requests_total');
const errorCounter = meter.createCounter('http_errors_total');
const durationHistogram = meter.createHistogram('http_request_duration_ms');

// Hook for RED metrics (express middleware)
const express = require('express');
const app = express();

app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    requestCounter.add(1);
    if (res.statusCode >= 400) errorCounter.add(1);
    durationHistogram.record(duration);
  });
  next();
});

// ---- Logs ----
const logExporter = new OTLPLogExporter({
  url: 'http://localhost:4318/v1/logs'
});

const loggerProvider = new LoggerProvider();
loggerProvider.addLogRecordProcessor(new SimpleLogRecordProcessor(logExporter));

const logger = loggerProvider.getLogger('monolith-app');

// Replace console.log
global.console.log = (msg) => {
  logger.emit({ severityText: 'INFO', body: msg });
};

// Start OTEL SDK
sdk.start();