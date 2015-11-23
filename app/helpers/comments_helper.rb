module CommentsHelper
  def build_comment(com, level)
    haml_tag :div, class: 'comment', 'data-level' => level, 'data-id' => com.id do
      haml_tag :div, class: 'row' do
        haml_tag :div, class: 'small-5 columns' do
          haml_tag :span, link_to("@#{html_escape_once(com.user.name)}", com.user)
        end
        if logged_in?
          haml_tag :div, class: 'small-5 columns text-right' do
            haml_tag :a, 'reply', class: 'reply-link'
          end
        end
      end
      haml_tag :div, class: 'row' do
        haml_tag :div, class: 'small-12 columns' do
          haml_tag :div, class: 'comment-dates' do
            haml_tag :div, class: 'comment-dates-row' do
              haml_tag :div, "Wrote on: #{com.c_at.to_s(:short)}", class: 'comment-written'
              haml_tag :div, '|', class: 'comment-separator'
              haml_tag :div, "Edited on: #{com.u_at.to_s(:short)}", class: 'comment-edited text-right'
            end
          end
        end
      end
      haml_tag :div, class: 'row' do
        haml_tag :div, class: 'small-10 small-offset-1 columns' do
          haml_tag :p, "#{html_escape_once(com.body)}"
        end
      end
    end
  end

  def generate_comment_list(com, level = 1)
    @max_level ||= level
    if level != 1
      haml_tag :div, class: 'row' do
        haml_tag :div, class: 'small-11 small-offset-1 columns' do
          build_comment(com, level)

          com.comments.each do |child|
            generate_comment_list child, level + 1
          end
        end
      end
    else
      build_comment(com, level)

      com.comments.each do |child|
        generate_comment_list child, level + 1
      end
    end

    @max_level = level if level > @max_level
  end
end
