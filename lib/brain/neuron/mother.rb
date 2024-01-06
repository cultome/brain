class Brain::Neuron::Mother
  attr_reader :type, :id, :name, :description, :path

  def initialize(type, id, name, description, path)
    @type = type
    @id = id
    @name = name
    @description = description
    @path = path
  end

  def text?
    false
  end

  def object?
    false
  end
end
