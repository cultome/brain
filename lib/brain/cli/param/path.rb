class Brain::Cli::Param::Path < Brain::Cli::Param::Base
  def path?
    true
  end

  def text?
    true
  end
end
