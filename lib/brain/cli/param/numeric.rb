class Brain::Cli::Param::Numeric < Brain::Cli::Param::Base
  def numeric?
    true
  end

  def text?
    true
  end
end
