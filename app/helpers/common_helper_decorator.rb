Spree::Core::ControllerHelpers::Common.module_eval do
  def default_title
    if @current_store
      @current_store.name
    else
      Spree::Config[:site_name]
    end
  end
end
