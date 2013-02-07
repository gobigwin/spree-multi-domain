module SpreeMultiDomain
  class Engine < Rails::Engine
    engine_name 'spree_multi_domain'

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end

      Spree::Config.searcher_class = Spree::Search::MultiDomain
      ApplicationController.send :include, SpreeMultiDomain::MultiDomainHelpers
    end

    config.to_prepare &method(:activate).to_proc

    initializer "templates with dynamic layouts" do |app|
      ActionView::TemplateRenderer.class_eval do
        def find_layout_with_multi_store(layout, locals)
          if layout.is_a? Proc
            store_layout = layout.call
          else
            store_layout = layout
          end

          if @view.respond_to?(:current_store) && @view.current_store && !@view.controller.is_a?(Spree::Admin::BaseController)
            store_layout.gsub!("spree/layouts/", "#{@view.current_store.code}/layouts/") if store_layout.is_a?(String)
          end

          begin
            find_layout_without_multi_store(store_layout, locals)
          rescue ::ActionView::MissingTemplate
            find_layout_without_multi_store(layout, locals)
          end
        end

        alias_method_chain :find_layout, :multi_store
      end
    end

    initializer "current order decoration" do |app|
      require 'spree/core/controller_helpers/order'
      ::Spree::Core::ControllerHelpers::Order.module_eval do
        def current_order_with_multi_domain(create_order_if_necessary = false)
          current_order_without_multi_domain(create_order_if_necessary)

          if @current_order and current_store and @current_order.store.nil?
            @current_order.update_attribute(:store_id, current_store.id)
          end

          @current_order
        end
        alias_method_chain :current_order, :multi_domain
      end
    end

    initializer "override partial rendering" do |app|
      ActionView::PartialRenderer.class_eval do
        def find_template(path=@path, locals=@locals.keys)
          prefixes = path.include?(?/) ? [] : @lookup_context.prefixes
          begin
            # This is a bit hacky to catch this much. Some @views will not have a @current_store. Kind of a catch all.
            # TODO: Clean up
            @lookup_context.find_template(path.gsub('spree/', "#{@view.current_store.code}/"), prefixes, true, locals, @details)
          rescue
            @lookup_context.find_template(path, prefixes, true, locals, @details)
          end
        end
      end
    end
  end
end
