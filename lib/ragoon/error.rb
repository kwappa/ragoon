class Ragoon::Error < StandardError
  def initialize(message = nil, details = {})
    super(message)
    @details = details
  end

  attr_reader :details

  def code
    @details['code']
  end

  def diagnosis
    @details['diagnosis']
  end

  def cause
    @details['cause']
  end

  def counter_measure
    @details['counter_measure']
  end
end
