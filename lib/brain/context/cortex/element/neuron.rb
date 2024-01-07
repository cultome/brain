class Brain::Context::Cortex::Element::Neuron < Brain::Context::Cortex::Element::Base
  def neuron?
    true
  end

  def to_s
    "#{@value.name} [#{@value.type}]"
  end
end
