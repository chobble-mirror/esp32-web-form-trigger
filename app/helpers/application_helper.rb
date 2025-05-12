module ApplicationHelper
  def display_image(image, size, options = {})
    return unless image.attached?

    variant = case size
    when :thumbnail
      ImageProcessorService.process(image, 200)
    when :medium
      ImageProcessorService.process(image, 800)
    when :large
      ImageProcessorService.process(image)
    else
      ImageProcessorService.process(image)
    end

    image_tag url_for(variant), options
  end
  
  def markdown(text)
    return "" if text.blank?
    
    renderer = Redcarpet::Render::HTML.new(
      filter_html: false,
      no_styles: true,
      no_images: false,
      no_links: false,
      safe_links_only: true,
      with_toc_data: false,
      hard_wrap: true
    )
    
    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true
    )
    
    sanitize(markdown.render(text), attributes: %w[href src alt])
  end
end
