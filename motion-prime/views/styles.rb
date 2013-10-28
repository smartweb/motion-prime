motion_require '../helpers/has_normalizer'
module MotionPrime
  class Styles
    FORM_FIELDS = [:field, :string_field, :date_field, :password_field, :select_field, :string_field, :submit_field, :switch_field, :table_field, :text_field, :text_with_button_field]

    @@repo = {}

    def initialize(namespace = nil)
      @namespace = namespace
    end

    def style(*args)
      names = Array.wrap(args)
      options = names.pop if args.last.is_a?(Hash)

      names.each do |name|
        name = "#{@namespace}_#{name}".to_sym if @namespace

        @@repo[name] ||= {}
        if parent = options.delete(:parent)
          parent ="#{@namespace}_#{parent}".to_sym if @namespace
          @@repo[name].deep_merge! self.class.for(parent)
        end
        @@repo[name].deep_merge! options
      end
    end

    def form_fields_selector(selectors = ':field')
      [*selectors].map do |selector|
        if selector.blank?
          FORM_FIELDS
        else
          FORM_FIELDS.map { |field| selector.to_s.gsub(':field', field.to_s).to_sym }
        end
      end.flatten
    end

    class << self
      include HasNormalizer

      def define(namespace = nil, &block)
        self.new(namespace).instance_eval(&block)
      end

      def for(style_names)
        style_options = {}
        Array.wrap(style_names).each do |name|
          style_options.deep_merge!(@@repo[name] || {})
        end
        style_options
      end

      def extend_and_normalize_options(options = {})
        style_options = self.for(options.delete(:styles))
        normalize_options(style_options.merge(options))
      end
    end
  end
end