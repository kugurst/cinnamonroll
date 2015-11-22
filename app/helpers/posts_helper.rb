module PostsHelper
  def buildComment(com, level)
    %(
<div class="comment" data-level="#{level}">
  <div class="row">
    <div class="small-6 columns">
      <span>@#{html_escape_once(com.user.name)}</span>
    </div>
  </div>
  <div class="row">
    <div class="small-4 columns">
      <span>Created at: #{com.c_at.to_s(:short)}</span>
    </div>
    <div class="small-4 columns text-right">
      <span>Updated at: #{com.u_at.to_s(:short)}</span>
    </div>
  </div>
  <div class="row">
    <div class="small-10 small-offset-1 columns">
      <p>#{html_escape_once(com.body)}</p>
    </div>
  </div>
</div>
)
  end

  def generateCommentList(com, level = 1)
    arr = buildComment(com, level).split "\n"


    ret = ''
    ret = %(
#{'  ' * level}<div class="row">
#{'  ' * (level + 1)}<div class="small-11 small-offset-1 columns">
) if level != 1
    arr.each do |line|
      ret += "  " * level + line + "\n"
    end

    com.comments.each do |child|
      ret += generateCommentList child, level + 1
    end
    ret += %(
#{'  ' * (level + 1)}</div>
#{'  ' * level}</div>) if level != 1
    ret
  end
end
