class Ragoon::Services
  SERVICE_LOCATIONS = {
    schedule: '/cbpapi/schedule/api?',
  }.freeze

  attr_reader :action_type

  def initialize
    @doc = Ragoon::Xml::Request.new
    @action_type = self.class.name.split('::').pop.downcase.to_sym
  end

  def endpoint
    endpoint = URI(Ragoon.garoon_endpoint)
    "#{endpoint.scheme}://#{endpoint.host}#{endpoint.path}#{SERVICE_LOCATIONS[action_type]}"
  end
end
