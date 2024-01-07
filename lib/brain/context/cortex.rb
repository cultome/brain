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
  end

  def pwd(*args)
    @current[:path]
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
      neurons = tmp[:neurons]
        .select { |n| n.name =~ /#{last_segment}/ }
        .map { |n| Element::Neuron.new n, n.name }

      dentrites = tmp[:dentrites].keys
        .select { |d| d =~ /#{last_segment}/ }
        .map { |d| Element::Dentrite.new d, "#{d}/" }
    end

    {
      value: neurons + dentrites,
      exact_match: last_segment.nil?,
    }
  end

  def show
    neuron = get_neuron_by_name cmd.params.first

    if neuron.nil?
      raise "Unable to find [#{cmd.params.first}]"
    else
      neuron.content
    end
  end

  #########
  # Utils #
  #########

  def completions_for(action, params)
    case action
    when 'cd'
      resp = ls params.first
      resp[:value].select(&:dentrite?).map { |d| "#{action} #{d.label}" }
    when 'ls'
      require 'pry'; binding.pry
      []
    when 'show'
      require 'pry'; binding.pry
      []
    else
      []
    end
  end

  def prompt
    pwd
  end

  def get_neuron_by_name(name)
    # TODO: implement
    @current[:neurons].first
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
