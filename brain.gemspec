# frozen_string_literal: true

require_relative 'lib/brain/version'

Gem::Specification.new do |spec|
  spec.name = 'brain'
  spec.version = Brain::VERSION
  spec.authors = ['Carlos Soria']
  spec.email = ['csoria@cultome.io']

  spec.summary = 'Second damaged brain'
  spec.description = 'Second damaged brain'
  spec.homepage = 'https://github.com/cultome/brain'
  spec.required_ruby_version = '>= 3.2'

  spec.metadata['allowed_push_host'] = 'https://github.com/cultome/brain'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/cultome/brain'
  spec.metadata['changelog_uri'] = 'https://github.com/cultome/brain'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(bin/ test/ spec/ features/ .git .circleci appveyor Gemfile))
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
