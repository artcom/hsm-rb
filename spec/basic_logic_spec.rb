require 'spec_helper'

describe 'basic logic' do
  it 'is still prevailing' do
    expect((2 + 2)).to eq(4)
    expect((2 + 2)).not_to eq(5)
  end
end
