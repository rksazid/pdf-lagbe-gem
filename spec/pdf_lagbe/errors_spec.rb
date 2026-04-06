# frozen_string_literal: true

RSpec.describe PdfLagbe::Error do
  it 'inherits from StandardError' do
    expect(described_class.superclass).to eq(StandardError)
  end

  it 'stores status and response details' do
    error = described_class.new('test', status: 500, response_body: 'body', response_headers: {})

    expect(error.status).to eq(500)
    expect(error.response_body).to eq('body')
    expect(error.response_headers).to eq({})
  end

  it 'uses a default message when none provided' do
    error = described_class.new
    expect(error.message).to eq('PdfLagbe API error')
  end
end

RSpec.describe PdfLagbe::BadRequestError do
  it 'inherits from ClientError' do
    expect(described_class.superclass).to eq(PdfLagbe::ClientError)
  end

  it 'has a default message' do
    expect(described_class.new.message).to eq('Bad request: validation failed')
  end
end

RSpec.describe PdfLagbe::RateLimitError do
  it 'exposes retry_after from headers' do
    error = described_class.new('rate limited', response_headers: { 'retry-after' => '30' })
    expect(error.retry_after).to eq(30)
  end

  it 'returns nil retry_after when no header' do
    error = described_class.new('rate limited')
    expect(error.retry_after).to be_nil
  end
end

RSpec.describe PdfLagbe::ServiceUnavailableError do
  it 'exposes retry_after from headers' do
    error = described_class.new('unavailable', response_headers: { 'retry-after' => '60' })
    expect(error.retry_after).to eq(60)
  end
end

RSpec.describe 'PdfLagbe::ERROR_MAP' do
  it 'maps 400 to BadRequestError' do
    expect(PdfLagbe::ERROR_MAP[400]).to eq(PdfLagbe::BadRequestError)
  end

  it 'maps 408 to TimeoutError' do
    expect(PdfLagbe::ERROR_MAP[408]).to eq(PdfLagbe::TimeoutError)
  end

  it 'maps 413 to PayloadTooLargeError' do
    expect(PdfLagbe::ERROR_MAP[413]).to eq(PdfLagbe::PayloadTooLargeError)
  end

  it 'maps 429 to RateLimitError' do
    expect(PdfLagbe::ERROR_MAP[429]).to eq(PdfLagbe::RateLimitError)
  end

  it 'maps 503 to ServiceUnavailableError' do
    expect(PdfLagbe::ERROR_MAP[503]).to eq(PdfLagbe::ServiceUnavailableError)
  end
end
