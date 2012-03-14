# Build navigational tabs as HTML table
module TabsHelper
  def tabs(select_current_page = true)
    tabs = Tabs.new(controller)
    yield tabs
    tabs.to_html(select_current_page).html_safe
  end

  class Tabs
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    
    attr_accessor :controller

    def initialize(controller)
      self.controller = controller
      @tabs = []
    end

    def add(name, options = {}, html_options = {}, &block)
      _html_options = { :class => "btn" }
      _html_options.merge!(html_options) if html_options
      @tabs << Tab.new(name, options, _html_options)
    end
    
    # Show tab named +name+ as selected
    def select(name)
      @selected_name = name
    end

    # Builder escapes text, which is not what we want
    def to_html(select_current_page = true)
      table_class = "tabs"
      table_class = "tabs_solo" if @tabs.size < 2
      html = <<HTML
     <div class="row"><div class="btn-group">
HTML
      @tabs.each_with_index do |tab, index|
        html << link_to(tab.name, tab.options, tab.html_options).to_s
      end
      end_html = <<HTML
    </div></div>
HTML
      html << end_html
    end
    
    # FIXME
    def _routes
      self.controller._routes
    end
    
    def request
      self.controller.request
    end
  end
  
  class Tab
    attr_reader :name, :options, :html_options

    def initialize(name, options, html_options)
      @name = name
      @options = options
      @html_options = html_options
    end
  end
end