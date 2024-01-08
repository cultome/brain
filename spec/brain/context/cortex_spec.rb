RSpec.describe Brain::Context::Cortex do
  let(:cortex) { described_class.new Brain.acquire_knowledge! }

  it 'navigates forward' do
    expect(cortex.pwd[:value]).to eq '/'

    cortex.cd Brain::Cli::Param.create_text 'me'

    expect(cortex.pwd[:value]).to eq '/me'

    expect(cortex.ls[:value].size).to eq 2
  end

  context '#=' do
    it 'calculates a math expression' do
      resp = cortex.>> Brain::Cli::Param.create_text '1+1'
      expect(resp[:value]).to eq '2'
    end
  end

  context '#ls' do
    it 'matches partial paths' do
      resp = cortex.ls Brain::Cli::Param.create_text 'm'
      expect(resp[:exact_match]).to be false
      expect(resp[:value].first.label).to eq 'me/'

      resp = cortex.ls Brain::Cli::Param.create_text 'me/'
      expect(resp[:exact_match]).to be true
      expect(resp[:value].map(&:label)).to eq ['me/mis_datos', 'me/banks/']

      resp = cortex.ls Brain::Cli::Param.create_text 'me/b'
      expect(resp[:exact_match]).to be false
      expect(resp[:value].map(&:label)).to eq ['me/banks/']
    end
  end
end
