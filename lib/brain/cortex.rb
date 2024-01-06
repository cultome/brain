class Brain::Cortex
  module Element
    class Neuron
      def initialize(neuron)
        @value = neuron
      end

      def to_s
        "#{@value.name} [#{@value.type}]"
      end
    end

    class Dentrite
      def initialize(name)
        @value = name
      end

      def to_s
        "#{@value}/"
      end
    end
  end

  def initialize(knowledge)
    @knowledge = knowledge
    @current = @knowledge
  end

  def pwd
    @current[:path]
  end

  def cd(path)
    return @current = @knowledge if path.nil?

    tmp = @current
    path.split('/').each do |segment|
      tmp = tmp[:dentrites][segment]
    end

    raise "Unable to navigate to path [#{path}] from [#{@current[:path]}]" if tmp.nil?

    @current = tmp
  end

  def ls
    neurons = @current[:neurons].map { |n| Element::Neuron.new n }
    dentrites = @current[:dentrites].keys.map { |d| Element::Dentrite.new d }

    neurons + dentrites
  end

  def get_neuron_by_name(name)
    # TODO: implement
    @current[:neurons].first
  end
end
