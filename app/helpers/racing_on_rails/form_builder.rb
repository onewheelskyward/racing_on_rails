module RacingOnRails
  # Label + form fields HTML. Wrap checkboxes in divs (probably should do this for all label + field chunks).
  class FormBuilder < ActionView::Helpers::FormBuilder
    # Set +editable+ to false for read-only
    def labelled_text_field(method, text = method.to_s.titleize, text_field_options = {})
      label_options = text_field_options.delete(:label) || {}
      if text_field_options[:editable] == false
        %Q{#{label(method, "#{text || method.to_s.titleize}", label_options)} <div class="labelled" id="#{object_name}_#{method}">#{@object.send(method)}</div>}.html_safe
      else
        %Q{<div class="text_field">#{label(method, "#{text || method.to_s.titleize}", label_options)} #{text_field(method, text_field_options)}</div>}.html_safe
      end
    end

    # Set +editable+ to false for read-only
    def labelled_select(method, select_options, options = {})
      label_options = options.delete(:label) || {}
      text = label_options.delete(:text) if label_options
      if options[:editable] == false
        %Q{#{label(method, "#{text || method.to_s.titleize}", label_options)} <div class="labelled" id="#{object_name}_#{method}">#{@object.send(method)}</div>}.html_safe
      else
        %Q{<div class="select">#{label(method, "#{text || method.to_s.titleize}", label_options)}<div class="input">#{select(method, select_options, options)}</div></div>}.html_safe
      end
    end

    def labelled_date_select(method, options = {})
      label_options = options.delete(:label) || {}
      text = label_options.delete(:text) if label_options
      _options = {
        :order => [:month, :day, :year], 
        :start_year => 1900,
        :end_year => Date.today.year, 
        :include_blank => true        
      }
      _options.merge!(options)
      %Q{<div class="select">#{label(method, "#{text || method.to_s.titleize}", label_options)}<div class="input">#{date_select(method, _options)}</div></div>}.html_safe
    end
    
    # List from Countries::COUNTRIES
    def labelled_country_select(method, options = {})
      labelled_select method, RacingAssociation.current.priority_country_options + Countries::COUNTRIES, options.merge(:label => { :text => "Country" })
    end
    
    def labelled_password_field(method, text = method.to_s.titleize, password_field_options = {})
      label_options = password_field_options.delete(:label) || {}
      %Q{<div class="password_field">#{label(method, "#{text}", label_options)} #{password_field(method, password_field_options)}</div>}.html_safe
    end

    # Set +editable+ to false for read-only
    def labelled_check_box(method, text = nil, check_box_options = {})
      label_options = check_box_options.delete(:label) || {}
      if check_box_options[:editable] == false
        %Q{#{label(method, "#{text || method.to_s.titleize}", label_options)} <div class="labelled" id="#{object_name}_#{method}">#{@object.send(method)}</div>}.html_safe
      else
        %Q{<div class="check_box">#{label(method, "#{check_box(method, check_box_options)}#{text || method.to_s.titleize}".html_safe || method.to_s.titleize)}</div>}.html_safe
      end
    end
    
    def labelled_radio_button(method, value, text = nil)
      %Q{<div class="radio">#{radio_button(method, value)}#{label(method, text || method.to_s.titleize)}</div>}.html_safe
    end
    
    # Set +editable+ to false for read-only
    def labelled_text_area(method, options = {})
      label_options = options.delete(:label) || {}
      text = label_options[:text] if label_options
      if options[:editable] == false
        %Q{#{label(method, "#{text || method.to_s.titleize}", :class => 'text_area')} <div class="labelled" id="#{object_name}_#{method}">#{@object.send(method)}</div>}.html_safe
      else
        %Q{<div class="textarea">#{label(method, "#{text || method.to_s.titleize}", :class => 'text_area')}<div class="input">#{text_area(method, options)}</div></div>}.html_safe
      end
    end
    
    def labelled_text(method, text = nil, label_text = nil, label_options = {})
      %Q{<div class="labelled_text">#{label(method, "#{label_text || method.to_s.titleize}", label_options)} <div class="input #{object_name}_#{method}">#{text || @object.send(method)}</div></div>}.html_safe
    end
  end
end