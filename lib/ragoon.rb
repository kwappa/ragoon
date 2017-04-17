require 'nokogiri'
require 'rest-client'
require 'time'

require 'ragoon/version'
require 'ragoon/xml'
require 'ragoon/client'
require 'ragoon/services'
require 'ragoon/services/schedule'
require 'ragoon/services/notification'
require 'ragoon/services/workflow'

module Ragoon
  @@secret_options = {}

  def self.default_options
    {
      endpoint: ENV['GAROON_ENDPOINT'] || secret_options[:garoon_endpoint] || raise_option_error('endpoint'),
      username: ENV['GAROON_USERNAME'] || secret_options[:garoon_username] || raise_option_error('username'),
      password: ENV['GAROON_PASSWORD'] || secret_options[:garoon_password] || raise_option_error('password'),
      version:  ENV['GAROON_VERSION']  || secret_options[:garoon_version]  || 4
    }
  end

  def self.raise_option_error(type)
    raise "must specify garoon_#{type} by ENV or `./.secret_options`."
  end

  private

  def self.secret_options
    if @@secret_options.empty?
      raise '`./.secret_options` is required.' unless File.exists?('./.secret_options')
      @@secret_options = eval(File.read('./.secret_options'))
    end
    @@secret_options
  end
end
