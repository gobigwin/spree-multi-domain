class StoreResolver < ::ActionView::FileSystemResolver
  def initialize(store)
    @store = store
    super("app/views")
  end

  def find_templates(name, prefix, partial, details)
    prefix = prefix.gsub('spree/', "#{@store.code}/") unless @store.nil?
    super(name, prefix, partial, details)
  end
end
