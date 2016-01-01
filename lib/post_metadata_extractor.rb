module PostMetadataExtractor
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

    # Let's now try opening the file
    File.open(path, 'r') do |f|
      f.each_line do |line|
        # This matches a line in HAML like:
        #   - content_for :post_title, 'hello'
        # and breaks it down into:
        #   :title => 'hello'
        # The funky bit captures a second argument that spans multiple lines, though I don't think that's legal in HAML
        m = /^\s*-\s*content_for\s*:([^,]+),\s*(((?!^-|^=|^%|^#|^\.).)*)/m.match line
        unless m.nil?
          # m[1] is the symbol
          key = m[1].split('post_', 2).last
          # m[2] is the content data
          val = eval m[2]
          metadata[key.to_sym] = val
        end
      end
    end

    metadata
  end
end
