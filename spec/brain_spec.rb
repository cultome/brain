# frozen_string_literal: true

RSpec.describe Brain do
  it 'creates neurons' do
    neuron = Brain.create_text_neuron('Datos personales', 'Solo un resumen de mi', '/me', 'Nombre: Carlos Soria')

    expect(neuron).to be_text
  end

  it 'acquire knowledge' do
    brain = Brain.acquire_knowledge!

    expect(brain[:dentrites]['me'][:neurons].first).to be_text
  end
end
