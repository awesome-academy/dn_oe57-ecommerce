class Admin::ProductsController < ApplicationController
  before_action :load_info_categories,
                only: %i(show index new create edit update)
  before_action :load_product, only: %i(show edit update)
  before_action :load_category, only: :create
  before_action :admin_user, only: %i(new create edit update)

  def index
    @pagy, @products = pagy(Product.newest,
                            items: Settings.orders.number_of_page_5)
  end

  def show
    @feedbacks = @product.feedbacks.newest
  end

  def new
    @product = Product.new
  end

  def edit; end

  def create
    @product = @category.products.build product_params
    if @product.save
      flash[:success] = t("success")
      redirect_to admin_products_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @product.update product_params
      flash[:success] = t("product_updated")
      redirect_to admin_products_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :price,
                                    :description, :quantity, :rating, :image)
  end

  def load_product
    @product = Product.find_by id: params[:id]
    return if @product

    flash[:danger] = t("product_not_found")
    redirect_to root_url
  end

  def load_category
    @category = Category.find_by id: params[:product][:category_id]
    return if @category

    flash[:danger] = t("category_not_found")
    redirect_to root_url
  end

  def admin_user
    return if current_user&.is_admin?

    redirect_to root_path
    flash[:alert] = t("not_permission")
  end
end
