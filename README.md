# OpenTelemetry Monolith Demo (GitHub Codespaces Lab)

## Lab Steps
1. **Open in Codespaces**
   - Fork this repo
   - Open in GitHub Codespaces

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Run the app**
   ```bash
   npm start
   ```
   App runs on port `3000`.

4. **Test routes**
   - `curl http://localhost:3000/`
   - `curl http://localhost:3000/error`

5. **Observe**
   - Traces generated for each request
   - RED metrics increment (`http_requests_total`, `http_errors_total`, `http_request_duration_ms`)
   - Logs exported via OpenTelemetry

---

## Reflection Questions
1. What are RED metrics, and why are they important for monitoring?
2. How does tracing help in troubleshooting a monolithic app?
3. Why is using OpenTelemetry logging more powerful than simple `console.log`?
