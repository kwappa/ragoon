class Ragoon::Services
  SERVICE_LOCATIONS = {
    schedule:     '/cbpapi/schedule/api.csp?',
    notification: '/cbpapi/notification/api.csp?',
    workflow:     '/cbpapi/workflow/api.csp?',
  }.freeze

  attr_reader :client, :action_type

  def initialize(options = Ragoon.default_options)
    @options = options
    @action_type = self.class.name.split('::').pop.downcase.to_sym
    @client = Ragoon::Client.new(self.endpoint, options)
  end

  def endpoint
    url = "#{base_endpoint}#{SERVICE_LOCATIONS[action_type]}"
    url.gsub!('.csp', '') if @options[:version].to_i == 3
    url
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

  def parse_time(str)
    return nil if str.nil?
    Time.parse(str).localtime
  end

  def to_date_str(time)
    return nil if time.nil?
    time.localtime.strftime('%F')
  end

  def to_datetime_str(time)
    return nil if time.nil?
    time.utc.strftime('%FT%TZ')
  end
end
