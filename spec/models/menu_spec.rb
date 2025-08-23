require 'rails_helper'

RSpec.describe Menu, type: :model do
  describe 'associations' do
    it { should have_and_belong_to_many(:menu_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
