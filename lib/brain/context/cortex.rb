class Brain::Context::Cortex
  RULES = {
    'cd' => {
      description: 'Navigate into your brain structure',
      param_templates: ['none', 'path'], # might be 'text|path,empty,numeric|text'
    },
    'ls' => {
      description: 'List neurons and dentrites in this location',
      param_templates: ['none', 'path'],
    },
    'pwd' => {
      description: 'Name/path of the current location',
      param_templates: ['none'],
    },
    'show' => {
      description: 'Show neuron context',
      param_templates: ['path'],
    },
    '>>' => {
      description: 'Evaluates expression',
      param_templates: ['text'],
    },
    'note' => {
      description: 'Creates a note',
      param_templates: ['text'],
    },
    'help' => {
      description: 'This help',
      param_templates: ['none'],
    },
  }.freeze

  def initialize(knowledge)
    @knowledge = knowledge
    @current = @knowledge
  end

  ############
  # Commands #
  ############

  def cd(path = nil)
    return @current = @knowledge if path.nil? || path.value.empty?

    tmp = @current
    path.value.split('/').each do |segment|
      tmp = tmp&.dig(:dentrites, segment)
    end

    raise "Unable to navigate to path [#{path.value}] from [#{@current[:path]}]" if tmp.nil?

    @current = tmp

    {
      success: true,
      display: :none,
      value: nil,
    }
  end

  def pwd(*args)
    {
      success: true,
      display: :text,
      value: @current[:path],
    }
  end

  def ls(path = nil)
    tmp = @current
    last_segment = nil
    path_value = path.nil? ? '' : path.value

    if !path_value.empty?
      path_value.split('/').each do |segment|
        local_dentrites = tmp[:dentrites].keys

        if local_dentrites.include? segment
          tmp = tmp[:dentrites][segment]
        else
          last_segment = segment
          break
        end
      end
    end

    if last_segment.nil?
      neurons = tmp[:neurons].map do |n|
        Element::Neuron.new n, path_value.empty? ? n.name : File.join(path_value, n.name)
      end

      dentrites = tmp[:dentrites].keys.map do |d|
        Element::Dentrite.new d, path_value.empty? ? File.join(d, '/') : File.join(path_value, d, '/')
      end
    else
      partial_path = path_value.gsub last_segment, ''

      neurons = tmp[:neurons]
        .select { |n| n.name =~ /#{last_segment}/ }
        .map { |n| Element::Neuron.new n, partial_path.empty? ? n.name : File.join(partial_path, n.name) }

      dentrites = tmp[:dentrites].keys
        .select { |d| d =~ /#{last_segment}/ }
        .map { |d| Element::Dentrite.new d, partial_path.empty? ? File.join(d, '/') : File.join(partial_path, d, '/') }
    end

    {
      success: true,
      display: :list,
      value: neurons + dentrites,
      exact_match: last_segment.nil?,
    }
  end

  def help(*args)
    help_msg = RULES.map do |cmd, data|
      usage = "#{cmd} <#{data[:param_templates].join('|')}>"

      "#{usage.ljust(20)} #{data[:description]}"
    end.join("\n")

    {
      success: true,
      display: :text,
      value: help_msg,
    }
  end

  def show(file = nil)
    *path, filename = file.value.split('/')

    node = path.reduce(@current) do |acc, segment|
      acc&.dig(:dentrites, segment)
    end

    neuron = node[:neurons].find { |n| n.name == filename }

    if neuron.nil?
      {
        success: false,
        display: :error,
        value: "Unable to find [#{filename}]",
      }
    else
      {
        success: true,
        display: :text,
        value: neuron.content,
      }
    end
  end

  def >>(expr = nil)
    resp = BasicObject.new.instance_eval expr.value

    {
      success: true,
      display: :text,
      value: resp.to_s,
    }
  end

  def note(text = nil)
    raise 'implement'
  end

  #########
  # Utils #
  #########

  def completions_for(action, params)
    case action
    when 'cd'
      ls(params.first)[:value].select(&:dentrite?).map { |d| "#{action} #{d.label}" }
    when 'ls'
      ls(params.first)[:value].map { |d| "#{action} #{d.label}" }
    when 'show'
      ls(params.first)[:value]
        .select(&:neuron?)
        .select { |elem| elem.value.text? }
        .map { |d| "#{action} #{d.label}" }
    else
      []
    end
  end

  def prompt
    pwd[:value]
  end

  def actions
    RULES.keys
  end

  def valid_action?(action)
    RULES.key? action
  end

  def valid_params?(action, params)
    param_templates = RULES.fetch(action, {})[:param_templates]

    return true if params.empty? && param_templates.include?('none')

    candidates = param_templates.map do |template|
      template
        .split(',')
        .map { |p| p.split('|') }
        .select { |tpx| tpx.size == params.size }
    end.delete_if(&:empty?).flatten(1)

    candidates.any? do |valid_templates|
      valid_templates.zip(params).all? { |t, p| p.send "#{t}?" }
    end
  end
end

require_relative './cortex/element'
