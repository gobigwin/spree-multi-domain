Spree::BaseHelper.module_eval do
  def meta_data_tags
    object = instance_variable_get('@'+controller_name.singularize)
    object ||= @current_store
    meta = {}

    if object.kind_of? ActiveRecord::Base
      meta[:keywords] = object.meta_keywords if object[:meta_keywords].present?
      meta[:description] = object.meta_description if object[:meta_description].present?
    end

    if meta[:description].blank? && object.kind_of?(Spree::Product)
      meta[:description] = strip_tags(object.description)
    end

    meta.reverse_merge!({
      :keywords => Spree::Config[:default_meta_keywords],
      :description => Spree::Config[:default_meta_description]
    })

    meta.map do |name, content|
      tag('meta', :name => name, :content => content)
    end.join("\n")
  end
end
