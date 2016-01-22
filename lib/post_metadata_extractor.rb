module PostMetadataExtractor
  ARRAY_TYPE_STRING = "array"

  def self.extract_from_path(path, real_path = false)
    # which costs more, string construction or an if statement?
    path = path.to_s unless path.is_a? String

    # get the path to the post source folder
    root = PostsHelper::POST_SOURCE_PATH.to_s
    # inspect the partition of this path
    phead, _, _ = path.partition root
    # If the head is non-empty, then let's assume we were given a relative path and try again
    begin
      return self.extract_from_path PostsHelper::POST_SOURCE_PATH.join(path).realpath, true if !phead.empty? && !real_path
    rescue Errno::ENOENT
      # the file doesn't exist anyway, so don't bother parsing
      return {}
    end

    metadata = {}

    # Get the metadata of the post in XML form
    pr = PostRenderer.new
    xml_str = pr.render file: path, layout: 'posts/get_post_content_xml'
    doc = Nokogiri::XML(xml_str)

    # Parse it using xpath
    xpath = doc.xpath("post")
    # Iterate over each key-value pair
    xpath.first.try(:children).try(:each) do |child|
      # Avoids empty elements
      unless child.name.casecmp('text') == 0
        # We assume types are strings if not specified.
        type = child[:type]
        if type == ARRAY_TYPE_STRING
          arr = []
          child.children.each do |value|
            arr << value.text unless value.blank?
          end
          metadata[child.name.to_sym] = arr
        else
          metadata[child.name.to_sym] = child.text
        end
      end
    end

    metadata
  end
end
