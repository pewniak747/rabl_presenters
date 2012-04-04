# encoding: utf-8
module RablPresenter
  class Base < SimpleDelegator
    attr_reader :context
    attr_accessor :default_url_options

    def initialize model, context, opts={}
      @context = context
      @links = self.class.links
      super(model)
    end

    def self.present object, context, options={}
      if object.kind_of? ::Enumerable
        Enumerable.new(object, context, options)
      elsif presenters.include?(options[:with])
        options[:with].new(object, context, options)
      else
        presenters.find { |p| p.applicable_to?(object) }
        presenter.nil? ? object : presenter.new(object, context, options)
      end
    end

    def self.present_enumerable collection, options={}
      define_method collection do
        present presented.send(collection), options
      end
    end

    def self.presenters
      presenters = []
      ObjectSpace.each_object(Class) do |klass|
        presenters << klass if klass.ancestors.include?(self)
      end
      presenters
    end

    def self.link rel, options={}, &block
      @links ||= []
      block = options[:href] unless block_given?
      @links << { rel: rel, href: block }.merge(options)
    end

    def self.links
      @links ||= []
    end

    def self.template name=nil
      @template ||= name
    end

    def links
      @links.map { |link|
        ret = link.dup
        ret[:href] = instance_exec(&ret[:href])
        ret
      }
    end

    def present object, options={}
      Base.present(object, context, options)
    end

    def presented
      __getobj__
    end

    def model_name
      presented.class.to_s.downcase 
    end

    def render partial
      context.instance_variable_set("@#{model_name}", self)
      context.view_context.render(:template => partial)
    end

    def to_json options={}
      render(self.class.template)
    end

    def method_missing method_name, *args, &block
      if method_name.to_s =~ /.*_path|_url$/ && context.respond_to?(method_name)
        context.send method_name, *args, &block
      else super
      end
    end
  end
end
