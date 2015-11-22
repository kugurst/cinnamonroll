module PostsHelper
  def buildComment(com, level)
    haml_tag :div, class: 'comment', 'data-level' => level do
      haml_tag :div, class: 'row' do
        haml_tag :div, class: 'small-6 columns' do
          haml_tag :span, "@#{html_escape_once(com.user.name)}"
        end
      end
      haml_tag :div, class: 'row' do
        haml_tag :div, class: 'small-4 columns' do
          haml_tag :span, "Created at: #{com.c_at.to_s(:short)}"
        end
        haml_tag :div, class: 'small-4 columns text-right' do
          haml_tag :span, "Updated at: #{com.u_at.to_s(:short)}"
        end
      end
      haml_tag :div, class: 'row' do
        haml_tag :div, class: 'small-10 small-offset-1 columns' do
          haml_tag :p, "#{html_escape_once(com.body)}"
        end
      end
    end
  end

  def generateCommentList(com, level = 1)
    @max_level ||= level
    if level != 1
      haml_tag :div, class: 'row' do
        haml_tag :div, class: 'small-11 small-offset-1 columns' do
          buildComment(com, level)

          com.comments.each do |child|
            generateCommentList child, level + 1
          end
        end
      end
    else
      buildComment(com, level)

      com.comments.each do |child|
        generateCommentList child, level + 1
      end
    end

    @max_level = level if level > @max_level
  end
end
