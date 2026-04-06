# frozen_string_literal: true

RSpec.describe PdfLagbe::Middleware::RaiseError do
  include_context 'with stubbed connection'

  it 'does not raise on 200' do
    stubs.get('/ok') { [200, {}, 'ok'] }

    expect { client.connection.get('/ok') }.not_to raise_error
  end

  it 'raises BadRequestError on 400' do
    stubs.get('/bad') { [400, {}, '{"error":"html is required"}'] }

    expect { client.connection.get('/bad') }
      .to raise_error(PdfLagbe::BadRequestError, 'html is required')
  end

  it 'raises TimeoutError on 408' do
    stubs.get('/timeout') { [408, {}, '{"error":"render timeout"}'] }

    expect { client.connection.get('/timeout') }
      .to raise_error(PdfLagbe::TimeoutError)
  end

  it 'raises PayloadTooLargeError on 413' do
    stubs.get('/large') { [413, {}, '{"error":"too large"}'] }

    expect { client.connection.get('/large') }
      .to raise_error(PdfLagbe::PayloadTooLargeError)
  end

  it 'raises RateLimitError on 429' do
    stubs.get('/rate') { [429, { 'retry-after' => '30' }, '{"error":"rate limited"}'] }

    expect { client.connection.get('/rate') }
      .to raise_error(PdfLagbe::RateLimitError)
  end

  it 'raises ServiceUnavailableError on 503' do
    stubs.get('/unavail') { [503, {}, '{"error":"at capacity"}'] }

    expect { client.connection.get('/unavail') }
      .to raise_error(PdfLagbe::ServiceUnavailableError)
  end

  it 'raises ServerError for unknown 5xx' do
    stubs.get('/err') { [502, {}, 'bad gateway'] }

    expect { client.connection.get('/err') }
      .to raise_error(PdfLagbe::ServerError)
  end

  it 'raises ClientError for unknown 4xx' do
    stubs.get('/err') { [404, {}, 'not found'] }

    expect { client.connection.get('/err') }
      .to raise_error(PdfLagbe::ClientError)
  end
end
