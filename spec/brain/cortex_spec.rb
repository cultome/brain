RSpec.describe Brain::Cortex do
  let(:cortex) { Brain::Cortex.new Brain.acquire_knowledge! }

  it 'navigates forward' do
    expect(cortex.pwd).to eq '/'

    cortex.cd 'me'

    expect(cortex.pwd).to eq '/me'

    expect(cortex.ls.size).to eq 1
  end
end
