module WlCheckLoggedtimeHelper

  def timeline_zoom_link(timeline, in_or_out)
    case in_or_out
    when :in
      if timeline.zoom < 5
        link_to_content_update l(:text_zoom_in),
          params.merge(timeline.params.merge(:zoom => (timeline.zoom + 1))),
          :class => 'icon icon-zoom-in'
      else
        content_tag(:span, l(:text_zoom_in), :class => 'icon icon-zoom-in').html_safe
      end

    when :out
      if timeline.zoom > 1
        link_to_content_update l(:text_zoom_out),
          params.merge(timeline.params.merge(:zoom => (timeline.zoom - 1))),
          :class => 'icon icon-zoom-out'
      else
        content_tag(:span, l(:text_zoom_out), :class => 'icon icon-zoom-out').html_safe
      end
    end
  end


end