# PdfLagbe

A professional Ruby gem for converting HTML, Markdown, and DOCX to PDF using the [pdf-lagbe](https://github.com/rksazid/pdf-lagbe) API service.

Supports full page configuration, custom headers/footers, JavaScript rendering, GitHub Flavored Markdown, DOCX file uploads, and is designed with an extensible architecture for adding more conversion types.

## Installation

Add to your Gemfile:

```ruby
gem "pdf_lagbe"
```

Then run:

```bash
bundle install
```

Or install directly:

```bash
gem install pdf_lagbe
```

## Quick Start

```ruby
require "pdf_lagbe"

# Configure (optional — defaults to https://pdf-lagbe.vercel.app)
PdfLagbe.configure do |config|
  config.base_url = "https://pdf-lagbe.vercel.app"
end

client = PdfLagbe.client

# HTML to PDF
client.html_to_pdf.convert(html: "<h1>Hello</h1>").save("hello.pdf")

# Markdown to PDF
client.markdown_to_pdf.convert(markdown: "# Hello World").save("hello.pdf")

# DOCX to PDF
client.docx_to_pdf.convert(file_path: "document.docx").save("document.pdf")
```

## Configuration

### Global Configuration

```ruby
PdfLagbe.configure do |config|
  config.base_url        = "https://pdf-lagbe.vercel.app"  # API base URL
  config.open_timeout    = 10     # Connection timeout (seconds)
  config.read_timeout    = 30     # Response timeout (seconds)
  config.write_timeout   = 30     # Request write timeout (seconds)
  config.max_retries     = 2      # Retry count for network errors
  config.retry_interval  = 1.0    # Seconds between retries
  config.logger          = Logger.new($stdout)  # Optional request logging
  config.proxy           = nil    # HTTP proxy URL
end
```

### Per-Client Configuration

For multiple environments or concurrent usage:

```ruby
staging = PdfLagbe::Client.new(
  base_url: "https://pdf-lagbe.onrender.com",
  read_timeout: 60
)

production = PdfLagbe::Client.new(
  base_url: "https://pdf-lagbe.vercel.app"
)

staging.html_to_pdf.convert(html: "<p>Test</p>")
production.html_to_pdf.convert(html: "<p>Production</p>")
```

## HTML to PDF

Converts HTML content (with full CSS/JS rendering) to PDF.

### Basic Usage

```ruby
client = PdfLagbe.client

result = client.html_to_pdf.convert(html: "<h1>My Document</h1>")
result.save("document.pdf")
```

### With All Options

```ruby
result = client.html_to_pdf.convert(
  html: "<h1>Report</h1><p>Content here...</p>",

  # Page settings
  format: "A4",            # A4, Letter, A3, Legal, Tabloid
  landscape: false,        # Page orientation
  scale: 1.0,              # Scale: 0.1 to 2.0
  preferCSSPageSize: false, # Use @page CSS sizing

  # Margins (CSS units)
  margin: {
    top: "20mm",
    right: "15mm",
    bottom: "20mm",
    left: "15mm"
  },

  # Background
  printBackground: true,   # Include background colors/images

  # Header & Footer
  displayHeaderFooter: true,
  headerTemplate: '<div style="font-size:10px; text-align:center; width:100%;">My Report</div>',
  footerTemplate: '<div style="font-size:10px; text-align:center; width:100%;"><span class="pageNumber"></span>/<span class="totalPages"></span></div>',

  # Wait options (for JavaScript-rendered content)
  waitForSelector: "#chart-loaded",  # Wait for CSS selector
  waitForTimeout: 2000               # Additional wait (0-5000 ms)
)
```

### Save Directly to File

```ruby
result = client.html_to_pdf.convert_to_file(
  html: "<h1>Invoice</h1>",
  output_path: "invoice.pdf",
  format: "A4",
  margin: { top: "10mm", bottom: "10mm" }
)
```

### HTML Parameters Reference

| Parameter | Type | Description |
|---|---|---|
| `html` | String | **Required.** HTML content (max 2 MB) |
| `format` | String | Page size: `A4`, `Letter`, `A3`, `Legal`, `Tabloid` |
| `landscape` | Boolean | Landscape orientation |
| `margin` | Hash | `{ top:, right:, bottom:, left: }` — CSS units (e.g., `"10mm"`) |
| `printBackground` | Boolean | Include background colors/images |
| `scale` | Float | Scale factor (0.1 to 2.0) |
| `displayHeaderFooter` | Boolean | Show header and footer |
| `headerTemplate` | String | Header HTML (max 10 KB) |
| `footerTemplate` | String | Footer HTML (max 10 KB) |
| `preferCSSPageSize` | Boolean | Use `@page` CSS sizing |
| `waitForSelector` | String | CSS selector to wait for before rendering |
| `waitForTimeout` | Integer | Additional wait in ms (0-5000) |

## Markdown to PDF

Converts GitHub Flavored Markdown (tables, task lists, code syntax highlighting, strikethrough) to PDF.

### Basic Usage

```ruby
client = PdfLagbe.client

result = client.markdown_to_pdf.convert(markdown: "# My Document\n\nHello **world**!")
result.save("document.pdf")
```

### With Options

```ruby
result = client.markdown_to_pdf.convert(
  markdown: <<~MD,
    # Quarterly Report

    ## Summary
    | Metric | Q1 | Q2 |
    |--------|-----|-----|
    | Revenue | $1M | $1.5M |

    ## Tasks
    - [x] Complete analysis
    - [ ] Send to stakeholders

    ```ruby
    puts "Code blocks with syntax highlighting!"
    ```
  MD
  format: "A4",
  landscape: false,
  margin: { top: "20mm", bottom: "20mm", left: "15mm", right: "15mm" },
  printBackground: true
)

result.save("report.pdf")
```

### Save Directly to File

```ruby
client.markdown_to_pdf.convert_to_file(
  markdown: "# Hello World",
  output_path: "hello.pdf",
  format: "Letter"
)
```

### Markdown Parameters Reference

| Parameter | Type | Description |
|---|---|---|
| `markdown` | String | **Required.** Markdown content (max 2 MB) |
| `format` | String | Page size: `A4`, `Letter`, `A3`, `Legal`, `Tabloid` |
| `landscape` | Boolean | Landscape orientation |
| `margin` | Hash | `{ top:, right:, bottom:, left: }` — CSS units |
| `printBackground` | Boolean | Include background colors/images |
| `scale` | Float | Scale factor (0.1 to 2.0) |
| `displayHeaderFooter` | Boolean | Show header and footer |
| `headerTemplate` | String | Header HTML (max 10 KB) |
| `footerTemplate` | String | Footer HTML (max 10 KB) |
| `preferCSSPageSize` | Boolean | Use `@page` CSS sizing |
| `waitForSelector` | String | CSS selector to wait for before rendering |
| `waitForTimeout` | Integer | Additional wait in ms (0-5000) |

## DOCX to PDF

Converts Microsoft Word `.docx` files to PDF via multipart file upload.

### Basic Usage

```ruby
client = PdfLagbe.client

result = client.docx_to_pdf.convert(file_path: "report.docx")
result.save("report.pdf")
```

### With Options

```ruby
result = client.docx_to_pdf.convert(
  file_path: "report.docx",
  format: "Letter",
  landscape: true
)

result.save("report.pdf")
```

### Save Directly to File

```ruby
client.docx_to_pdf.convert_to_file(
  file_path: "input.docx",
  output_path: "output.pdf",
  format: "A4"
)
```

### DOCX Parameters Reference

| Parameter | Type | Description |
|---|---|---|
| `file_path` | String | **Required.** Path to `.docx` file (max 5 MB) |
| `format` | String | Page size: `A4`, `Letter`, `A3`, `Legal`, `Tabloid` |
| `landscape` | Boolean | Landscape orientation |

## Response Object

All `convert` methods return a `PdfLagbe::Response`:

```ruby
result = client.html_to_pdf.convert(html: "<p>Hello</p>")

result.body             # => Raw PDF binary data
result.status           # => 200
result.headers          # => Response headers hash
result.content_type     # => "application/pdf"
result.pdf?             # => true
result.size             # => Byte size of the PDF
result.generation_time  # => "150ms" (from X-Generation-Time header)
result.save("out.pdf")  # => Writes PDF to disk, returns the path
```

## Health Check & Service Info

```ruby
client = PdfLagbe.client

# Health check
health = client.health.check
# => { status: "idle", browser: { connected: true }, memory: { ... }, uptime: 12345 }

# Service info
info = client.info.fetch
# => { service: "pdf-lagbe", version: "1.0.0", endpoints: [...] }
```

## Error Handling

All API errors are mapped to typed exceptions:

```ruby
begin
  client.html_to_pdf.convert(html: "<p>Hello</p>")
rescue PdfLagbe::BadRequestError => e
  # 400 — Validation failure
  puts e.message
rescue PdfLagbe::PayloadTooLargeError => e
  # 413 — Content exceeds size limit
  puts e.message
rescue PdfLagbe::RateLimitError => e
  # 429 — Too many requests
  puts "Retry after #{e.retry_after} seconds"
rescue PdfLagbe::TimeoutError => e
  # 408 — Render timed out
  puts e.message
rescue PdfLagbe::ServiceUnavailableError => e
  # 503 — Server at capacity
  puts "Retry after #{e.retry_after} seconds"
rescue PdfLagbe::ConnectionError => e
  # Network-level failure
  puts e.message
rescue PdfLagbe::Error => e
  # Catch-all for any API error
  puts "#{e.status}: #{e.message}"
end
```

### Error Hierarchy

```
PdfLagbe::Error
├── PdfLagbe::ClientError
│   ├── PdfLagbe::BadRequestError        (400)
│   ├── PdfLagbe::PayloadTooLargeError   (413)
│   └── PdfLagbe::RateLimitError         (429)
├── PdfLagbe::ServerError
│   ├── PdfLagbe::TimeoutError           (408)
│   └── PdfLagbe::ServiceUnavailableError(503)
└── PdfLagbe::ConnectionError
```

All errors expose:
- `e.status` — HTTP status code
- `e.response_body` — Raw response body
- `e.response_headers` — Response headers
- `e.retry_after` — Seconds to wait (on `RateLimitError` and `ServiceUnavailableError`)

Client-side validation raises `ArgumentError` before making the request:

```ruby
client.html_to_pdf.convert(html: "")              # => ArgumentError: html is required
client.html_to_pdf.convert(html: "x", scale: 5)   # => ArgumentError: scale must be between 0.1 and 2.0
client.markdown_to_pdf.convert(markdown: "")       # => ArgumentError: markdown is required
client.docx_to_pdf.convert(file_path: "test.txt")  # => ArgumentError: file must be a .docx file
```

## Rails Integration

```ruby
# config/initializers/pdf_lagbe.rb
PdfLagbe.configure do |config|
  config.base_url     = ENV.fetch("PDF_LAGBE_URL", "https://pdf-lagbe.vercel.app")
  config.read_timeout = 60
  config.logger       = Rails.logger
end
```

```ruby
# app/controllers/invoices_controller.rb
class InvoicesController < ApplicationController
  def download
    html = render_to_string(template: "invoices/show", layout: "pdf")
    result = PdfLagbe.client.html_to_pdf.convert(
      html: html,
      format: "A4",
      printBackground: true,
      margin: { top: "15mm", bottom: "15mm", left: "10mm", right: "10mm" }
    )

    send_data result.body,
              filename: "invoice_#{@invoice.number}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end
end
```

```ruby
# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  def export_markdown
    markdown = File.read(Rails.root.join("docs", "report.md"))
    result = PdfLagbe.client.markdown_to_pdf.convert(
      markdown: markdown,
      format: "A4",
      printBackground: true
    )

    send_data result.body,
              filename: "report.pdf",
              type: "application/pdf"
  end

  def export_docx
    result = PdfLagbe.client.docx_to_pdf.convert(
      file_path: params[:file].tempfile.path
    )

    send_data result.body,
              filename: "converted.pdf",
              type: "application/pdf"
  end
end
```

## Extending for Future Endpoints

The gem uses a resource-based architecture. Adding a new conversion type requires only 3 steps:

**1. Create a new resource:**

```ruby
# lib/pdf_lagbe/resources/image_to_pdf.rb
module PdfLagbe
  module Resources
    class ImageToPdf < Base
      ENDPOINT = "/api/v1/image-to-pdf"

      def convert(file_path:, **options)
        # Implementation here
      end
    end
  end
end
```

**2. Add accessor to Client:**

```ruby
# In lib/pdf_lagbe/client.rb
def image_to_pdf
  @image_to_pdf ||= Resources::ImageToPdf.new(self)
end
```

**3. Require it in `lib/pdf_lagbe.rb` and use:**

```ruby
client.image_to_pdf.convert(file_path: "photo.png")
```

## Development

```bash
git clone https://github.com/rksazid/pdf-lagbe-gem.git
cd pdf-lagbe-gem
bin/setup

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop

# Interactive console
bin/console
```

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
