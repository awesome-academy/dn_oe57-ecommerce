require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do

  describe 'DELETE #destroy' do
    let(:user1) {create :user, email: "default1@gmal.com", is_admin: true}
    let(:category1) {create :category, name: "Category 1"}
    let!(:product1) {create :product, category_id: category1.id}
    let(:params) {{id: product1.id}}

    before do
      sign_in(user1)
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
      let(:user1) {create :user, email: "default2@gmal.com", is_admin: false}

      context "message user is not admin" do
        it do
          expect(flash[:alert]) == (I18n.t("not_permission"))
        end
      end
    end

  end

end
