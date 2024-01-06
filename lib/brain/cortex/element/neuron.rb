class Brain::Cortex::Element::Neuron
  def initialize(neuron)
    @value = neuron
  end

  def to_s
    "#{@value.name} [#{@value.type}]"
  end
end
