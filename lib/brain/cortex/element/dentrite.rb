class Brain::Cortex::Element::Dentrite
  def initialize(name)
    @value = name
  end

  def to_s
    "#{@value}/"
  end
end
