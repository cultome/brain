class Brain::Cli::Param::Base
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def none?
    false
  end

  def path?
    false
  end

  def text?
    false
  end

  def numeric?
    false
  end

  def type
    self.class.name.split('::').last.downcase
  end
end
