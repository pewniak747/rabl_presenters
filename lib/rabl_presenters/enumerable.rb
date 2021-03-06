module RablPresenter
  class Enumerable < Base
    include ::Enumerable

    def initialize models, context, options={}
      @presenter = options[:with]
      super
    end

    def each(*)
      super do |obj|
        yield present(obj, with: @presenter)
      end
    end

    def to_ary
      to_a
    end

    def self.applicable_to? object
      object.kind_of? ::Enumerable
    end
  end
end
