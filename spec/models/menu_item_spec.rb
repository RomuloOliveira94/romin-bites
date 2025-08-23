require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  describe 'associations' do
    it { should have_and_belong_to_many(:menus) }
  end

  describe 'validations' do
    subject { build(:menu_item) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end
end
