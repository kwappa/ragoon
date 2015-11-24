class Ragoon::Services
  SERVICE_LOCATIONS = {
    schedule:     '/cbpapi/schedule/api?',
    notification: '/cbpapi/notification/api?',
  }.freeze

  attr_reader :client, :action_type

  def initialize
    @action_type = self.class.name.split('::').pop.downcase.to_sym
    @client = Ragoon::Client.new(self.endpoint)
  end

  def endpoint
    endpoint = URI(Ragoon.garoon_endpoint)
    "#{endpoint.scheme}://#{endpoint.host}#{endpoint.path}#{SERVICE_LOCATIONS[action_type]}"
  end

  def self.start_and_end(date = Date.today)
    {
      start: Time.local(date.year, date.month, date.day,     0).utc,
      end:   Time.local(date.year, date.month, date.day + 1, 0).utc,
    }
  end
end
