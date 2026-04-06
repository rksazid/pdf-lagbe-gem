# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-04-06

### Added

- Initial release
- HTML to PDF conversion via `POST /api/v1/pdf`
- Full parameter support: format, landscape, margin, scale, printBackground, displayHeaderFooter, headerTemplate, footerTemplate, preferCSSPageSize, waitForSelector, waitForTimeout
- Client-side validation for all parameters
- Health check endpoint (`GET /health`)
- Service info endpoint (`GET /`)
- Configurable base URL, timeouts, retries, logging, and proxy
- Per-client configuration for multi-environment usage
- Typed error hierarchy mapped to HTTP status codes (400, 408, 413, 429, 503)
- Automatic retry on network failures and 503 responses
- Response object with `save`, `pdf?`, `generation_time`, and `size` helpers
- RSpec test suite with 97%+ coverage
