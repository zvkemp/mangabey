require "bundler/setup"
require "mangabey"

require 'webmock'
require 'vcr'
require 'pry-byebug'
require 'dotenv'

WebMock.disable_net_connect!

Dotenv.load
external_ip = `dig +short myip.opendns.com @resolver1.opendns.com`
VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
  config.default_cassette_options = {
    match_requests_on: [:method, :path, :body, :query]
  }

  config.filter_sensitive_data('<REDACTED>') do
    ENV['MANGABEY_ACCESS_TOKEN']
  end

  config.filter_sensitive_data('1.2.3.4') { external_ip }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around(vcr: true) do |ex|
    scoped_id = ex.example.metadata[:scoped_id]
    file_path = ex.example.metadata[:file_path].tr('/', '_')
    VCR.use_cassette("sm-#{file_path}-#{scoped_id}", &ex)
  end
end

Mangabey::LOGGER.level = Logger::DEBUG
