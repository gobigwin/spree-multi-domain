Spree::Core::ControllerHelpers::Common.module_eval do
  def default_title
    @current_store.name || Spree::Config[:site_name]
  end
end
