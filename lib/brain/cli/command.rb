class Brain::Cli::Command
  attr_reader :action, :params, :context

  def initialize(action, params, context)
    @context = context

    @valid_action, @valid_params, @action, @params = validate_command action, params
  end

  def completions
    return context.actions.grep(/^#{action}/) unless valid_action?

    return [] if context.nil?

    context.completions_for action, params
  end

  def valid_params?
    @valid_params
  end

  def valid_action?
    @valid_action
  end

  def valid?
    @valid_action && @valid_params
  end

  def execute
    if !action.nil? && context.respond_to?(action)
      context.send action, *params
    else
      nil
    end
  end

  private

  def validate_command(action, params)
    return [false, false, nil, nil] if action.nil?

    return [false, false, action, nil] unless context.valid_action?(action)

    classified_params = classify_params params

    return [true, false, action, params] unless context.valid_params?(action, classified_params)

    [true, true, action, classified_params]
  end

  def classify_params(params)
    return [] if params.nil?

    params.map do |param|
      if param =~ /^[\d]+(.[\d]+)?$/
        Brain::Cli::Param.create_numeric param.to_f
      else
        Brain::Cli::Param.create_text param.to_s
      end
    end
  end
end
