Spree::Admin::ProductsController.class_eval do
  update.before :set_stores

  private
  def set_stores
    unless ((params[:product].key? :store_ids) || 
            (params[:product].key? :product_properties_attributes))
      @product.store_ids = nil
    end
  end

end
