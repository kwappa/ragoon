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
      endpoint: ENV['GAROON_ENDPOINT'] || raise_option_error('endpoint'),
      username: ENV['GAROON_USERNAME'] || raise_option_error('username'),
      password: ENV['GAROON_PASSWORD'] || raise_option_error('password'),
      version:  ENV['GAROON_VERSION']  || 4
    }
  end

  def self.raise_option_error(type)
    raise "must specify garoon_#{type} by ENV or `./.secret_options`."
  end

  private

  def self.secret_options
    if @@secret_options.empty?
      if File.exist?('./.secret_options')
        @@secret_options = eval(File.read('./.secret_options'))
      else
        @@secret_options = default_options
      end
    end
    @@secret_options
  end
end
