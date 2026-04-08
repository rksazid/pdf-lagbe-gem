# frozen_string_literal: true

require_relative 'lib/pdf_lagbe/version'

Gem::Specification.new do |spec|
  spec.name          = 'pdf_lagbe'
  spec.version       = PdfLagbe::VERSION
  spec.authors       = ['Md Rezaul Karim']
  spec.email         = ['rksazid@gmail.com']

  spec.summary       = 'Ruby client for the pdf-lagbe PDF generation API'
  spec.description   = 'A professional Ruby gem for converting HTML, Markdown, and DOCX to PDF using the ' \
                       'pdf-lagbe API service. Supports full page configuration, custom headers/footers, ' \
                       'and is designed with an extensible architecture for future conversion types.'
  spec.homepage      = 'https://github.com/rksazid/pdf-lagbe-gem'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.0'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri']   = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?('spec/', 'test/', '.git', '.github', 'bin/')
    end
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '>= 2.0', '< 3.0'
  spec.add_dependency 'faraday-multipart', '~> 1.0'
  spec.add_dependency 'faraday-retry', '~> 2.0'
end
