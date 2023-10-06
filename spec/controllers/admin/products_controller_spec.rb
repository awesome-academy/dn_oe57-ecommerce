require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do
  let(:admin) {create :user, email: "default1@gmal.com", is_admin: true}
  let(:category1) {create :category, name: "Category 1"}
  let!(:product1) {create :product, category_id: category1.id}


  describe "GET #index" do
    before do
      sign_in(admin)
      get :index
    end

    context "When user is admin" do
      it "assigns @products" do
        expect(assigns(:products)) == ([product1])
      end

      it "render the index template" do
        expect(response).to render_template("index")
      end
    end

    context "When user is not admin" do
      let(:admin) {create :user, email: "admin2@gmal.com", is_admin: false}

      it "message user not admin" do
        expect(flash[:danger]) == (I18n.t("not_admin"))
      end

      it "redirect to root" do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET #new" do
    before do
      sign_in(admin)
      get :new
    end

    context "When user is admin" do
      it "render new product template" do
        expect(response).to render_template("new")
      end
    end

    context "When user is not admin" do
      let(:admin) {create :user, email: "admin2@gmal.com", is_admin: false}

      it "message user not admin" do
        expect(flash[:danger]) == (I18n.t("not_admin"))
      end

      it "redirect to root" do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST #create" do
    let(:valid_params) { { product: { name: 'Test Product', price: 100000, description: 'Product description', quantity: 12, rating: 0, category_id: category1.id } } }
    let(:invalid_params) { { product: { name: '', price: 0, description: '', quantity: 1200, rating: 0, category_id: category1.id } } }

    before do
      sign_in(admin)
    end

    context "When user is admin" do
      context 'create success' do
        before do
          post :create, params: valid_params
        end

        it 'add a new product' do
          expect {post :create, params: valid_params}.to change(Product, :count).by(1)
        end

        it 'redirects to the products index page' do
          expect(response).to redirect_to(admin_products_path)
        end

        it "message create success" do
          expect(flash[:success]).to eq(I18n.t('success'))
        end
      end

      context 'create faild' do
        before do
          post :create, params: invalid_params
        end

        context 'with invalid parameters' do
          it 'does not create a new product' do
            expect {
              post :create, params: invalid_params
            }.to_not change(Product, :count)
          end

          it 'renders the new template' do
            expect(response).to render_template(:new)
          end

          it 'unprocessable entity' do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "category not found" do
          let(:invalid_params) { { product: { name: '', price: 0, description: '', quantity: 1200, rating: 0, category_id: 0 } } }

          it "message category not found" do
            expect(flash[:danger]).to eq(I18n.t('category_not_found'))
          end

          it "redirect to root" do
            expect(response).to redirect_to(root_path)
          end
        end
      end
    end

    context "When user is not admin" do
      let(:admin) {create :user, email: "default12@gmal.com", is_admin: false}

      before do
        post :create, params: valid_params
      end

      it "message user not admin" do
        expect(flash[:alert]).to eq(I18n.t("not_permission"))
      end

      it "redirect to root" do
        expect(response).to redirect_to(root_path)
      end
    end

  end

  describe "PUT #update" do
    let(:valid_params) { { id: product1.id, product: { name: 'Updated Name', description: 'Updated Description' } } }
    let(:invalid_params) { { id: product1.id, product: { name: '', description: '' } } }

    before do
      sign_in(admin)
    end

    context "When user is admin" do
      context "update success" do
        before do
          patch :update, params: valid_params
          product1.reload
        end

        it "updated success" do
          expect(product1.name).to eq('Updated Name')
          expect(product1.description).to eq('Updated Description')
        end

        it "redirects to the products index page" do
          expect(response).to redirect_to(admin_products_path)
        end

        it "sets a success flash message" do
          expect(flash[:success]).to eq(I18n.t('product_updated'))
        end

      end

      context 'update faild' do
        before do
          patch :update, params: invalid_params
          product1.reload
        end

        context 'with invalid parameters' do
          it 'does not update the product' do
            expect(product1.name).to_not be_blank
            expect(product1.description).to_not be_blank
          end

          it 'renders the edit template' do
            expect(response).to render_template(:edit)
          end

          it 'unprocessable entity' do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

      end
    end

    context "When user is not admin" do
      let(:admin) {create :user, email: "default15@gmal.com", is_admin: false}

      before do
        patch :update, params: valid_params
      end

      it "message user not admin" do
        expect(flash[:alert]).to eq(I18n.t("not_permission"))
      end

      it "redirect to root" do
        expect(response).to redirect_to(root_path)
      end
    end

  end

  describe 'DELETE #destroy' do
    let(:params) {{id: product1.id}}

    before do
      sign_in(admin)
      delete :destroy, params: params
    end

    context "When user is admin" do
      context "delete success" do
        it do
          expect(product1.reload.deleted_at).not_to eq nil
        end
      end

      context "product is not found" do
        let(:params) {{id: 0}}

        context "message product is not found" do
          it do
            expect(flash[:danger]) == (I18n.t("product_not_found"))
          end
        end

        context "redirect to root" do
          it do
            expect(response).to redirect_to(root_url)
          end
        end
      end
    end

    context "When user is not admin" do
      let(:admin) {create :user, email: "default2@gmal.com", is_admin: false}

      context "message user is not admin" do
        it do
          expect(flash[:alert]) == (I18n.t("not_permission"))
        end
      end
    end

  end

end
