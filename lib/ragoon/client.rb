class Ragoon::Client
  attr_reader :endpoint, :response

  def initialize(endpoint, options)
    @endpoint = endpoint
    @options = options
  end

  def request(action_name, body_node)
    retry_count = @options[:retry].to_i

    retry_count.times do
      begin
        request_once(action_name, body_node)
        return
      rescue Ragoon::Error => e
        unless e.message.include?('指定された画面はアクセスできません。')
          raise e
        end
        sleep(0.5)
      end
    end
    raise Ragoon::Error("試行回数が#{retry_count}回を超えたので終了しました。")
  end

  def result_set
    @result_set ||= Nokogiri::XML.parse(response.body)
  end

  def reset
    @result_set = nil
  end

  private

  def request_once(action_name, body_node)
    reset
    @action_name = action_name
    @body_node = body_node
    @response = RestClient.post(endpoint, Ragoon::XML.render(action_name, body_node, @options))
  ensure
    raise_error unless result_set.xpath('//soap:Fault').empty?
  end

  def raise_error
    raise Ragoon::Error.new(
      result_set.xpath('//soap:Reason').text.strip,
      result_set.xpath('//soap:Detail/*').map { |c| [c.name, c.text.strip] }.to_h
    )
  end
end
