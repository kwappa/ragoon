module Ragoon::XML
  ACTION_PLACEHOLDER = '<!-- REQUEST_ACTION -->'.freeze
  BODY_PLACEHOLDER   = '<!-- REQUEST_BODY -->'.freeze

  def self.render(action_name, body_node)
    template.dup.
      gsub!(ACTION_PLACEHOLDER, action_name).
      gsub!(BODY_PLACEHOLDER,   body_node.to_xml)
  end

  def self.create_node(name, attributes = {})
    node = Nokogiri::XML::Node.new(name, Nokogiri::XML.parse('<xml />'))
    attributes.each do |key, value|
      node[key.to_s] = value
    end
    node
  end

  def self.template
    <<"XML"
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://www.w3.org/2003/05/soap-envelope"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
                   xmlns:base_services="http://wsdl.cybozu.co.jp/base/2008">
  <SOAP-ENV:Header>
    <Action SOAP-ENV:mustUnderstand="1"
            xmlns="http://schemas.xmlsoap.org/ws/2003/03/addressing">
      #{ACTION_PLACEHOLDER}
    </Action>
    <Security xmlns:wsu="http://schemas.xmlsoap.org/ws/2002/07/utility"
              SOAP-ENV:mustUnderstand="1"
              xmlns="http://schemas.xmlsoap.org/ws/2002/12/secext">
      <UsernameToken wsu:Id="id">
        <Username>#{Ragoon.garoon_username}</Username>
        <Password>#{Ragoon.garoon_password}</Password>
      </UsernameToken>
    </Security>
    <Timestamp SOAP-ENV:mustUnderstand="1" Id="id"
               xmlns="http://schemas.xmlsoap.org/ws/2002/07/utility">
      <Created>#{Time.now.iso8601}</Created>
      <Expires>#{(Time.now + 60 * 60 * 24).iso8601}</Expires>
    </Timestamp>
    <Locale>jp</Locale>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    #{BODY_PLACEHOLDER}
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
XML
  end
end
