require 'rails_helper'

RSpec.describe SessionController, type: :controller do
  let(:user) { create(:user) }

  describe "POST #create" do
    context "with valid credentials" do
      it "logs in the user" do
        post :create, params: { session: { email: user.email, password: user.password } }
        expect(session[:user_id]).to eq(user.id)
      end

      it "redirects to root_path" do
        post :create, params: { session: { email: user.email, password: user.password } }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid credentials" do
      it "renders the new template" do
        post :create, params: { session: { email: 'invalid@example.com', password: 'wrongpassword' } }
        expect(response).to render_template(:new)
      end

      it "sets flash message" do
        post :create, params: { session: { email: 'invalid@example.com', password: 'wrongpassword' } }
        expect(flash[:danger]) == (I18n.t("invalid_email_password_combination"))
      end
    end
  end
end
