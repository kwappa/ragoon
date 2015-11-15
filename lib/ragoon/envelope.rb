class Ragoon::Envelope
  def self.doc_template
    Nokogiri::XML(xml_template)
  end

  def self.xml_template
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
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
XML
  end
end
