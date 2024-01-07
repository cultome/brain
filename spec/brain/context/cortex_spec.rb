RSpec.describe Brain::Context::Cortex do
  let(:cortex) { described_class.new Brain.acquire_knowledge! }

  it 'navigates forward' do
    expect(cortex.pwd).to eq '/'

    cortex.cd Brain::Cli::Param.create_text 'me'

    expect(cortex.pwd).to eq '/me'

    expect(cortex.ls.size).to eq 2
  end

  context '#ls' do
    it 'matches partial paths' do
      # resp = cortex.ls Brain::Cli::Param.create_text 'm'
      # expect(resp[:exact_match]).to be false
      # expect(resp[:value].first.label).to eq 'me/'

      resp = cortex.ls Brain::Cli::Param.create_text 'me/'
      expect(resp[:value].map(&:label)).to eq ['me/mis_datos', 'me/banks/']
    end
  end
end
