require 'ragoon/version'
require 'ragoon/services'
require 'ragoon/xml/request'

Dir.glob('./lib/ragoon/services/*.rb', &method(:require))

require 'nokogiri'
require 'rest-client'

module Ragoon
  @@secret_options = {}

  def self.garoon_endpoint
    ENV['GAROON_ENDPOINT'] || secret_options[:garoon_endpoint] || raise_option_error('endpoint')
  end

  def self.garoon_username
    ENV['GAROON_USERNAME'] || secret_options[:garoon_username] || raise_option_error('username')
  end

  def self.garoon_password
    ENV['GAROON_PASSWORD'] || secret_options[:garoon_password] || raise_option_error('password')
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
