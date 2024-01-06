class Brain::Neuron::Text < Brain::Neuron::Mother
  attr_reader :content

  def initialize(name, id, description, path, content)
    super Brain::Neuron::TEXT_TYPE, id, name, description, path

    @content = content
  end

  def text?
    true
  end
end
