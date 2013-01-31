class StoreResolver < ::ActionView::FileSystemResolver
  def initialize(store)
    @store = store
    super("app/views")
  end

  def find_templates(name, prefix, partial, details)
    super(name, prefix.gsub('spree/', "#{@store.code}/"), partial, details)
  end
end
