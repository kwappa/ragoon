class Ragoon::Services
  SERVICE_LOCATIONS = {
    schedule:     '/cbpapi/schedule/api?',
    notification: '/cbpapi/notification/api?',
    workflow:     '/cbpapi/workflow/api?',
  }.freeze

  attr_reader :client, :action_type

  def initialize(options = Ragoon.default_options)
    @options = options
    @action_type = self.class.name.split('::').pop.downcase.to_sym
    @client = Ragoon::Client.new(self.endpoint, options)
  end

  def endpoint
    "#{base_endpoint}#{SERVICE_LOCATIONS[action_type]}"
  end

  def self.start_and_end(date = Date.today)
    {
      start: date.to_time.utc,
      end:   ((date + 1).to_time - 1).utc,
    }
  end

  def garoon_endpoint
    base_endpoint
  end

  private

  def base_endpoint
    endpoint = URI(@options[:endpoint])
    "#{endpoint.scheme}://#{endpoint.host}#{endpoint.path}"
  end

end
