class Brain::Context::Cortex::Element::Base
  attr_reader :value, :label

  def initialize(value, label)
    @value = value
    @label = label
  end

  def neuron?
    false
  end

  def dentrite?
    false
  end
end
