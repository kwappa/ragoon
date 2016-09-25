require 'ragoon'
require 'test/unit'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
end

TEST_ENDPOINT_OPTS = {
  endpoint: 'http://onlinedemo2.cybozu.info/scripts/garoon/grn.exe',
  username: 'sato',
  password: 'sato'
}

module TestHelper

  def cassette_scope(scope_path)
    @@cassete_scope = scope_path
  end

  def test_with_cassette(description, &block)
    test description do
      previx = @@cassete_scope.nil? ? '' : @@cassete_scope + "__"
      VCR.use_cassette(previx + description) do
        instance_eval(&block)
      end
    end
  end
end

