require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  describe "GET #index" do
    let(:category) {create(:category)}
    let!(:product) {create(:product, name: "Áo product",price:12000, quantity:20,description: "Mo ta", category: category)}
    let!(:product1) {create(:product, name: "Clothes",price:12000, quantity:20,description: "Mo ta", category: category)}
    let!(:product2) {create(:product, name:"Giày dép", price:12000, quantity:20,description: "Mo ta", category: category)}

    context "with search by name" do
      it "result by name in params" do
        get :index, params: { q: { name_cont: "Áo" } }
        expect(assigns(:products)).to include(product)
      end

      it "not result by name in params" do
        get :index, params: { q: { name_cont: "123alo" } }
        expect(assigns(:products)).to be_empty
      end
    end

    context "with search by category" do
      it "result by id of category in params" do
        get :index, params: { id: category.id }
        expect(assigns(:products)).to include(product1, product2)
      end

      it "not result by id of category in params" do
        get :index, params: { id: 12 }
        expect(assigns(:products)).not_to include(product1, product2)
      end
    end

    context "with default search" do
      it "loads products with default search" do
        get :index
        expect(assigns(:products)).to include(product,product1, product2)
      end
    end
  end
end
