class Ragoon::Services::Schedule < Ragoon::Services
  def request
    @doc.action = 'ScheduleGetEvents'
    response = RestClient.post(endpoint, @doc.to_xml)
    @response = Nokogiri::XML.parse(response.body)
  end
end
