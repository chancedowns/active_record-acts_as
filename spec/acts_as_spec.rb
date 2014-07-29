require 'models'

RSpec.describe "ActiveRecord::Base model with #acts_as called" do
  subject { Pen }

  let(:pen_attributes) { {name: 'pen', price: 0.8, color: 'red'} }
  let(:pen) { Pen.new pen_attributes }

  it "has a has_one relation" do
    association = subject.reflect_on_all_associations.find { |r| r.name == :product }
    expect(association).to_not be_nil
    expect(association.macro).to eq(:has_one)
    expect(association.options).to have_key(:as)
  end

  describe "#acting_as?" do
    it "returns true for supermodel class and name" do
      expect(Pen.acting_as? :product).to be true
      expect(Pen.acting_as? Product).to be true
    end

    it "returns false for anything other than supermodel" do
      expect(Pen.acting_as? :model).to be false
      expect(Pen.acting_as? String).to be false
    end
  end

  describe ".acting_as?" do
    it "returns true for supermodel class and name" do
      expect(pen.acting_as? :product).to be true
      expect(pen.acting_as? Product).to be true
    end

    it "returns false for anything other than supermodel" do
      expect(pen.acting_as? :model).to be false
      expect(pen.acting_as? String).to be false
    end
  end

  describe "#is_a?" do
    it "responds true when supermodel passed to" do
      expect(Pen.is_a? Product).to be true
      expect(Pen.is_a? Object).to be true
      expect(Pen.is_a? String).to be false
    end
  end

  describe ".is_a?" do
    it "responds true when supermodel passed to" do
      expect(pen.is_a? Product).to be true
      expect(pen.is_a? Object).to be true
      expect(pen.is_a? String).to be false
    end
  end

  describe "#acting_as_name" do
    it "return acts_as model name" do
      expect(pen.acting_as_name).to eq('product')
    end
  end

  describe "#acting_as" do
    it "returns autobuilded acts_as model" do
      expect(pen.acting_as).to_not be_nil
      expect(pen.acting_as).to be_instance_of(Product)
    end
  end

  it "have supermodel attributes accessible on creation" do
    expect{Pen.create(pen_attributes)}.to_not raise_error
  end

  context "instance" do
    it "responds to supermodel methods" do
      %i(name name= name? name_change name_changed? name_was name_will_change! price color).each do |name|
        expect(pen).to respond_to(name)
      end
      expect(pen.present).to eq("pen - $0.8")
    end

    it "saves supermodel attributes on save" do
      pen.save
      pen.reload
      expect(pen.name).to eq('pen')
      expect(pen.price).to eq(0.8)
      expect(pen.color).to eq('red')
    end

    it "raises NoMethodEror on unexisting method call" do
      expect { pen.unexisted_method }.to raise_error(NoMethodError)
    end

    it "destroies Supermodel on destroy" do
      pen.save
      product_id = pen.product.id
      pen.destroy
      expect { Product.find(product_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "validates supermodel attribures upon validation" do
      p = Pen.new
      expect(p).to be_invalid
      expect(p.errors.keys).to include(:name, :price, :color)
      p.name = 'testing'
      expect(p).to be_invalid
      p.color = 'red'
      expect(p).to be_invalid
      p.price = 0.8
      expect(p).to be_valid
    end
  end
end