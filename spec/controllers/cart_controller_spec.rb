require 'rails_helper'

RSpec.describe CartController, type: :controller do
  let(:user) {create :user, email: "user1@gmail.com"}
  let(:category1) {create :category, name: "Category 1"}
  let!(:product1) {create :product, category_id: category1.id, price: 10}
  let!(:product2) {create :product, category_id: category1.id, price: 20}
  let(:params) {{ id: product1.id }}

  describe "GET #index" do
    context "When user is logged in" do
      before do
        sign_in(user)
        get :index
      end

      it "Render cart template" do
        expect(response).to render_template("index")
      end

      context "Total price all products into cart" do
        before do
          session[:cart] = { product1.id.to_s => 2, product2.id.to_s => 3 }
          @expected_total_price = (product1.price * 2) + (product2.price * 3)
          get :index
        end

        it "Check total price" do
          expect(assigns(:total_price)).to eq(@expected_total_price)
        end
      end
    end

    context "When user login not yet" do
      before do
        get :index
      end

      it "message please log in" do
        expect(flash[:danger]) == (I18n.t("please_log_in"))
      end

      it "redirect log in template" do
        expect(response).to redirect_to(login_url)
      end
    end

  end

  describe "GET #add_to_cart" do
    context "When user is logged in" do
      before do
        sign_in(user)
        get :add_to_cart, params: params
      end

      context "When quantity of products still in existence" do
        it "adds a product to the cart" do
          expect(session[:cart][product1.id.to_s]).to eq(1)
        end

        it "redirects to the product page" do
          expect(response).to redirect_to(product1)
        end

        context "Load total price all products into cart" do
          before do
            session[:cart] = { product1.id.to_s => 2, product2.id.to_s => 3 }
            @expected_total_price = (product1.price * 3) + (product2.price * 3)
            get :add_to_cart, params: params
          end

          it "Check total price" do
            expect(assigns(:total_price)).to eq(@expected_total_price)
          end
        end
      end

      context "When quantity of products out of stock" do
        let!(:product1) {create :product, category_id: category1.id, price: 10, quantity: 0}

        it "message product out of stock" do
          expect(flash[:danger]) == (I18n.t("out_of_stock"))
        end

        it "Redirect to the product page" do
          expect(response).to redirect_to(product1)
        end
      end

      context "when product not found" do
        let(:params) {{ id: 0 }}

        it "message product not found" do
          expect(flash[:danger]) == (I18n.t("product_not_found"))
        end

        it "Redirect to root" do
          expect(response).to redirect_to(root_url)
        end
      end
    end

    context "When user login not yet" do
      before do
        get :add_to_cart, params: params
      end

      it "message please log in" do
        expect(flash[:danger]) == (I18n.t("please_log_in"))
      end

      it "redirect log in template" do
        expect(response).to redirect_to(login_url)
      end
    end
  end

  describe "GET #increases_quantity_cart" do
    context "When user is logged in" do
      before do
        sign_in(user)
        session[:cart] = { product1.id.to_s => 2 }
        get :increase_quantity_cart, params: { id: product1.id }
      end

      context "increases the quantity of a product in the cart" do
        it "update quantity product in cart" do
          expect(session[:cart][product1.id.to_s]).to eq(3)
        end

        context "Load total price all products into cart" do
          before do
            session[:cart] = { product1.id.to_s => 2, product2.id.to_s => 3 }
            @expected_total_price = (product1.price * 3) + (product2.price * 3)
            get :increase_quantity_cart, params: params
          end

          it "Check total price" do
            expect(assigns(:total_price)).to eq(@expected_total_price)
          end
        end
      end

      context "when product not found" do
        before do
          get :increase_quantity_cart, params: { id: 0 }
        end

        it "message product not found" do
          expect(flash[:danger]) == (I18n.t("product_not_found"))
        end

        it "Redirect to root" do
          expect(response).to redirect_to(root_url)
        end
      end
    end

    context "When user login not yet" do
      before do
        get :increase_quantity_cart, params: params
      end

      it "message please log in" do
        expect(flash[:danger]) == (I18n.t("please_log_in"))
      end

      it "redirect log in template" do
        expect(response).to redirect_to(login_url)
      end
    end
  end

  describe "GET #decrease_quantity_cart" do
    context "When user is logged in" do
      before do
        sign_in(user)
        session[:cart] = { product1.id.to_s => 2 }
        get :decrease_quantity_cart, params: { id: product1.id }
      end

      context "decrease the quantity of a product in the cart" do
        it "update quantity product in cart" do
          expect(session[:cart][product1.id.to_s]).to eq(1)
        end

        context "Load total price all products into cart" do
          before do
            session[:cart] = { product1.id.to_s => 2, product2.id.to_s => 3 }
            @expected_total_price = (product1.price * 1) + (product2.price * 3)
            get :decrease_quantity_cart, params: params
          end

          it "Check total price" do
            expect(assigns(:total_price)).to eq(@expected_total_price)
          end
        end
      end

      context "when product not found" do
        before do
          get :decrease_quantity_cart, params: { id: 0 }
        end

        it "message product not found" do
          expect(flash[:danger]) == (I18n.t("product_not_found"))
        end

        it "Redirect to root" do
          expect(response).to redirect_to(root_url)
        end
      end
    end

    context "When user login not yet" do
      before do
        get :decrease_quantity_cart, params: params
      end

      it "message please log in" do
        expect(flash[:danger]) == (I18n.t("please_log_in"))
      end

      it "redirect log in template" do
        expect(response).to redirect_to(login_url)
      end
    end
  end

  describe "POST #remove_to_cart" do
    context "When user is logged in" do
      before do
        sign_in(user)
        session[:cart] = { product1.id.to_s => 2 }
        get :remove_to_cart, params: { id: product1.id }
      end

      context "removes a product from the cart" do
        it "update cart" do
          expect(session[:cart][product1.id.to_s]).to be_nil
        end

        context "Load total price all products into cart" do
          before do
            session[:cart] = { product1.id.to_s => 2, product2.id.to_s => 3 }
            @expected_total_price = product2.price * 3
            get :remove_to_cart, params: { id: product1.id }
          end

          it "Check total price" do
            expect(assigns(:total_price)).to eq(@expected_total_price)
          end
        end

        context "when product not found" do
          before do
            get :remove_to_cart, params: { id: 0 }
          end

          it "message product not found" do
            expect(flash[:danger]) == (I18n.t("product_not_found"))
          end

          it "Redirect to root" do
            expect(response).to redirect_to(root_url)
          end
        end
      end
    end

    context "When user login not yet" do
      before do
        get :remove_to_cart, params: params
      end

      it "message please log in" do
        expect(flash[:danger]) == (I18n.t("please_log_in"))
      end

      it "redirect log in template" do
        expect(response).to redirect_to(login_url)
      end
    end
  end

end
