require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  let!(:user) { create(:user) }
  let!(:valid_order_attributes) { attributes_for(:order, user_id: user.id) }
  let!(:invalid_order_attributes) { attributes_for(:order, reciver_phone: nil) }
  let!(:category) {create(:category)}
  let!(:product) {create(:product, category_id: category.id)}

  before(:each) do
    session[:user_id] = user.id
  end

  before(:each) do
    session[:cart] = { "476" => 1 }
  end

  describe "POST #create" do
    context "creates a new order success" do
      it "render flash success" do
        post :create, params: { order: valid_order_attributes }
        expect(flash[:success]).to eq(I18n.t("success"))
      end

      it "redirect to root path on success" do
        post :create, params: { order: valid_order_attributes }
        expect(response).to redirect_to(root_path)
      end
    end

    context "creates a new order failure" do
      it "render flash failure" do
        post :create, params: { order: invalid_order_attributes }
        expect(flash[:notice]).to eq(I18n.t("error"))
      end

      it "renders the cart/index template on failure" do
        post :create, params: { order: invalid_order_attributes }
        expect(response).to render_template("cart/index")
      end
    end

    context "check order in orderdetail" do
      it "create order detail success" do
        post :create, params: { order: valid_order_attributes }
        order_detail = OrderDetail.first
        expect(order_detail.order_id).to eq(assigns(:order).id)
      end

      it "create order detail failure" do
        post :create, params: { order: invalid_order_attributes }
        expect(assigns(:order_details)).to be_nil
      end
    end

    context "check quantity product after order" do
      it "order success and change quantity of product success" do
        product_check = Product.first
        quantity_product_in_order = session[:cart]["476"]
        post :create, params: { order: valid_order_attributes }
        order_detail = OrderDetail.first
        product_after_order = Product.find_by id: order_detail.product_id
        expect(product_check.quantity).to eq(product_after_order.quantity + quantity_product_in_order)
      end
    end
  end
end
