module Brain::Cli::Param
  extend self

  def create_numeric(value)
    Brain::Cli::Param::Numeric.new value
  end

  def create_text(value)
    Brain::Cli::Param::Text.new value
  end
end

require_relative './param/base'
require_relative './param/text'
require_relative './param/numeric'
