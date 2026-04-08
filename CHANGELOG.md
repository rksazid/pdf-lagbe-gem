# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2026-04-08

### Added

- Markdown to PDF conversion via `POST /api/v1/md-to-pdf`
  - GitHub Flavored Markdown support (tables, task lists, code highlighting, strikethrough)
  - All PDF options (format, margin, scale, headers/footers, etc.)
  - Client-side validation for markdown content (required, max 2 MB)
- DOCX to PDF conversion via `POST /api/v1/docx-to-pdf`
  - Multipart file upload for `.docx` files (max 5 MB)
  - Format and landscape options
  - Client-side validation (file existence, extension, size)
- Shared `PdfOptions` validation module for DRY option validation across resources
- `faraday-multipart` dependency for file upload support

### Changed

- HTML-to-PDF endpoint updated from `/api/v1/pdf` to `/api/v1/html-to-pdf`
- Gem description updated to reflect HTML, Markdown, and DOCX support
- Refactored `HtmlToPdf` to use shared `PdfOptions` module

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
