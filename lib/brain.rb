# frozen_string_literal: true

require 'securerandom'

require_relative 'brain/version'
require_relative 'brain/neuron'

module Brain
  extend self

  KNOWLEDGE_FOLDER = '.knowledge'

  def new_id
    SecureRandom.uuid.gsub '-', ''
  end

  def create_text_neuron(name, description, path, content)
    Neuron::Text.new(name, new_id, description, path, content)
  end

  def acquire_knowledge!(folder = KNOWLEDGE_FOLDER)
    brain = { path: '/', neurons: [], dentrites: {} }

    Dir.children(folder)
      .map { |filename| File.join folder, filename }
      .each do |filepath|
      if File.directory? filepath
        brain = acquire_knowledge! filepath
      else
        content = File.read filepath
        lines = content.split("\n")

        path = filepath.split('/')[1..-2].join('/')
        type = nil
        name = nil
        description = nil
        content = nil

        loop do
          line = lines.shift

          if line.start_with? 'type: '
            type = line.gsub(/^type:\s*/, '')
          elsif line.start_with? 'name: '
            name = line.gsub(/^name:\s*/, '')
          elsif line.start_with? 'description: '
            description = line.gsub(/^description:\s*/, '')
          elsif line.start_with? '---: '
            content = lines.join("\n")
            break
          else
            break
          end
        end

        case type
        when 'text'
          neuron = create_text_neuron name, description, path, content

          path.split('/').reduce('/') do |acc, segment|
            new_path = File.join(acc, segment)
            brain[:dentrites][segment] ||= { path: new_path, neurons: [], dentrites: {} }

            new_path
          end

          brain_section = path.split('/').reduce(brain) do |acc, segment|
            acc[:dentrites][segment]
          end

          brain_section[:neurons] << neuron
        end
      end
    end

    brain
  end
end
