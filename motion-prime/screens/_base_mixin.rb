motion_require "./_aliases_mixin"
motion_require "./_orientations_mixin"
motion_require "./_navigation_mixin"
module MotionPrime
  module ScreenBaseMixin
    extend ::MotionSupport::Concern

    include ::MotionSupport::Callbacks
    include MotionPrime::ScreenAliasesMixin
    include MotionPrime::ScreenOrientationsMixin
    include MotionPrime::ScreenNavigationMixin

    attr_accessor :parent_screen, :modal, :params, :main_section, :options, :tab_bar
    class_attribute :current_screen

    included do
      define_callbacks :load
    end

    def app_delegate
      UIApplication.sharedApplication.delegate
    end

    def show_sidebar
      app_delegate.show_sidebar
    end

    def hide_sidebar
      app_delegate.hide_sidebar
    end

    def on_screen_load
      run_callbacks :load do
        on_load
      end
    end

    # Setup the screen, this method will be called when you run MPViewController.new
    # @param options [hash] Options passed to setup
    # @return [MotionPrime::Screen] Ready to use screen
    def on_create(options = {})
      unless self.is_a?(UIViewController)
        raise StandardError.new("ERROR: Screens must extend UIViewController.")
      end

      self.options = options
      self.params = options[:params] || {}
      options.each do |k, v|
        self.send("#{k}=", v) if self.respond_to?("#{k}=")
      end
      self
    end

    def modal?
      !!self.modal
    end

    def title
      title = self.class.title
      title = self.instance_eval(&title) if title.is_a?(Proc)
      title
    end

    def title=(new_title)
      self.class.title(new_title)
    end

    def main_controller
      has_navigation? ? navigation_controller : self
    end

    def refresh
      main_section.try(:reload_data)
    end

    # Class methods
    module ClassMethods
      def title(t = nil, &block)
        if block_given?
          @title = block
        else
          t ? @title = t : @title ||= self.to_s
        end
      end
      def before_load(method_name)
        set_callback :load, :before, method_name
      end
      def after_load(method_name)
        set_callback :load, :after, method_name
      end
      def create_with_options(screen, navigation = true, options = {})
        if screen.is_a?(Symbol)
          options[:navigation] = navigation unless options.has_key?(:navigation)
          screen = class_factory("#{screen}_screen").new(options)
        end
        screen
      end
    end
  end
end