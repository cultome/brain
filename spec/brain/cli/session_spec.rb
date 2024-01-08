RSpec.describe Brain::Cli::Session do
  let(:session) do
    knowledge = Brain.acquire_knowledge!
    cortex = Brain::Context::Cortex.new knowledge

    described_class.new cortex
  end

  context '#parse_command' do
    it 'parse a valid command' do
      cmd = session.parse_command 'cd me'

      expect(cmd).to be_valid
      expect(cmd.action).to eq 'cd'
      expect(cmd.params.size).to eq 1
      expect(cmd.params.first.value).to eq 'me'
    end

    it 'parse an invalid action' do
      cmd = session.parse_command 'wrong command'

      expect(cmd).not_to be_valid
    end

    it 'validate no-parameters' do
      cmd = session.parse_command 'cd'

      expect(cmd).to be_valid
      expect(cmd.action).to eq 'cd'
      expect(cmd.params).to be_empty
    end

    it 'validate invalid parameters' do
      cmd = session.parse_command 'cd 12345'
      expect(cmd).not_to be_valid

      cmd = session.parse_command 'cd uno dos'
      expect(cmd).not_to be_valid
    end
  end

  context '#completions_for' do
    it 'suggest actions' do
      options = session.completions_for 'c'
      expect(options).to eq ['cd']
    end

    it 'suggest params' do
      options = session.completions_for 'cd'
      expect(options).to eq ['cd me/']
    end

    it 'suggest path params' do
      options = session.completions_for 'cd me'
      expect(options).to eq ['cd me/banks/']

      options = session.completions_for 'cd me/banks'
      expect(options).to eq ['cd me/banks/bigmoney/']
    end
  end
end
