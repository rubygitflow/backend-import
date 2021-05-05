class ProductsController < ApplicationController
  def index
    @products = Product.all
  end

  def import
    begin
      Product.import(params[:file])
      redirect_to products_path, notice: "Products added successfully"
    rescue CSV::MalformedCSVError => e
      redirect_to products_path, notice: "Error in the input data structure: #{e.message}"
    rescue Exception => e
      redirect_to products_path, notice: "Something went wrong: #{e.message}"
    end
  end
end
