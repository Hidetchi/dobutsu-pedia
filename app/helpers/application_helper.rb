module ApplicationHelper

  def piece_img_tag(type, size = 75, directory = 'hidetchi')
    str = type == 0 ? "" : "<img class='piece' width=#{size.to_s} height=#{size.to_s} src='/assets/#{directory}/#{type.to_s}.png'>"
    str.html_safe
  end
end
