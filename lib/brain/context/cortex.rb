class Brain::Context::Cortex
  RULES = {
    'cd' => {
      param_templates: ['', 'text'],
    },
    'ls' => {
      param_templates: ['', 'text'],
    },
    'pwd' => {
      param_templates: [''],
    },
    'show' => {
      param_templates: ['text'],
    },
    'exit' => {
      param_templates: [''],
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
      require 'pry'; binding.pry
      []
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
    actual_form = params.map { |c| c.type }.join(',')

    RULES.fetch(action, {})[:param_templates].include? actual_form
  end
end

require_relative './cortex/element'
