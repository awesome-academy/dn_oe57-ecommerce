class CartController < ApplicationController
  include CartHelper
  before_action :authorize_user

  before_action :load_product, only: %i(add_to_cart remove_to_cart
    decrease_quantity_cart increase_quantity_cart)
  after_action :total_price, only: %i(add_to_cart remove_to_cart
    decrease_quantity_cart increase_quantity_cart)
  before_action :load_product_in_cart, :total_price, only: :index
  before_action :check_quantity, only: :add_to_cart

  def index; end

  def add_to_cart
    session[:cart] ||= {}
    handle_product_quantity
    respond_to do |format|
      flash[:success] =
        t("add_to_cart_noti") + " #{view_context.link_to(t('shopping_cart'),
                                                         cart_index_path)}"
      format.html{redirect_to @product}
      format.js
    end
  end

  def increase_quantity_cart
    if session[:cart].key?(@product.id.to_s)
      session[:cart][@product.id.to_s] += 1
    else
      flash[:danger] = t("product_not_found_reload_page")
    end
    respond_to do |format|
      handle_quantity_warning

      format.html{redirect_to cart_index_path}
      format.js
    end
  end

  def decrease_quantity_cart
    if session[:cart].key?(@product.id.to_s)
      session[:cart][@product.id.to_s] -= 1
    else
      flash[:danger] = t("product_not_found_reload_page")
    end
    respond_to do |format|
      format.html{redirect_to cart_index_path}
      format.js
    end
  end

  def remove_to_cart
    session[:cart].delete(@product.id.to_s)

    respond_to do |format|
      format.html{redirect_to cart_index_path}
      format.js
    end
  end

  private

  def handle_product_quantity
    session[:cart][@product.id.to_s] ||= 0
    session[:cart][@product.id.to_s] += 1
  end

  def load_product
    @product = Product.find_by id: params[:id]
    return if @product

    flash[:danger] = t("product_not_found")
    redirect_to root_url
  end

  def handle_quantity_warning
    return unless session[:cart][@product.id.to_s] == @product.quantity

    flash[:warning] = t("invalid_quantity")
  end

  def check_quantity
    return if @product.quantity.positive?

    flash[:danger] = t("out_of_stock")
    redirect_to @product
  end

  def authorize_user
    authorize! :manage, :cart
  end
end
