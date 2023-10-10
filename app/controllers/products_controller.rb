class ProductsController < ApplicationController
  load_and_authorize_resource
  before_action :load_info_categories, only: %i(show index)
  before_action :load_product, only: %i(show)

  def show
    @feedbacks = @product.feedbacks.newest
  end

  def new
    @product = Product.new
  end

  def index
    if params[:name].present?
      search_by_name
    elsif params[:id].present?
      search_by_category
    else
      default_search
    end
    handle_empty_search(@products)
    render "static_pages/home"
  end

  private

  def product_params
    params.require(:product).permit(:name, :price,
                                    :description, :quantity, :rating, :image)
  end

  def search_by_name
    search_results = Product.search_by_name(params[:name])
    @pagy, @products = pagy(search_results,
                            items: Settings.products.number_of_page_10)
  end

  def search_by_category
    @children_categories = Category.find_id_or_parent(params[:id])
    children_category_id = @children_categories.pluck(:id)
    search_results = if @children_categories.length == 1
                       Product.filter_by_category_id(params[:id])
                     else
                       Product.filter_by_category_id(children_category_id)
                     end
    @pagy, @products = pagy(search_results,
                            items: Settings.products.number_of_page_10)
  end

  def default_search
    search_results = Product.all
    @pagy, @products = pagy(search_results,
                            items: Settings.products.number_of_page_10)
  end

  def handle_empty_search search_results
    flash.now[:notice] = "Không tìm thấy sản phẩm nào." if search_results.empty?
  end

  def load_product
    @product = Product.find_by id: params[:id]
    return if @product

    flash[:danger] = t("product_not_found")
    redirect_to root_url
  end

  def load_category
    category_search = Category.search_by_name(params[:name])
    @category = Category.find_id(category_search.pluck(:id))
  end
end
