require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
