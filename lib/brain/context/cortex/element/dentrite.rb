class Brain::Context::Cortex::Element::Dentrite < Brain::Context::Cortex::Element::Base
  def dentrite?
    true
  end

  def to_s
    "#{@value}/"
  end
end
