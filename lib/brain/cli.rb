module Brain::Cli
  def self.start_session(context)
    Session.new(context).start!
  end
end

require_relative './cli/param'
require_relative './cli/command'
require_relative './cli/session'
