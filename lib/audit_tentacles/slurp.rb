FILES_REGEX = /\.flv|\.swf|\.png|\.jpg|\.gif|\.asx|\.zip|\.rar|\.tar|\.7z|\.gz|\.jar|\.mp3|\.mp4|\.wav|\.wmv|\.ape|\.aac|\.ac3|\.wma|\.aiff|\.mpg|\.mpeg|\.avi|\.mov|\.ogg|\.mkv|\.mka|\.asx|\.asf|\.mp2|\.m1v|\.m3u|\.f4v|\.pdf|\.doc|\.ppt|\.pps|\.bin|\.exe|\.docx|\.pptx/

module Slurp
  def slurp(page)
    links = page.doc.css('a')
    if links
      links = filter_links(links)
    end
    images = page.doc.css('img')
    if images
      images = get_srcs(images)
    end
    links + images
  end


  def get_srcs(images)
    srcs = images.map { |img| img.attribute('src').to_s }
    srcs.delete_if { |ref| ref !~  FILES_REGEX }
    srcs.delete_if { |src| src =~ /\/design\// }
    clean_and_absolute srcs
  end


  def filter_links(links)
    links = links.map { |link| link.attribute('href').to_s }
    links.delete_if { |ref| ref !~  FILES_REGEX }
    clean_and_absolute links
  end


  def clean_and_absolute(links)
    links.delete_if { |str| str == nil }
    abs = []
    links.map do |link|
      if link =~ /^\//
        abs << "#{@site}" + link
      end
    end
    abs.delete_if { |ref| ref !~ /\.tki\.org\.nz/ }
    abs
  end
end
