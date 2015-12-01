module ApplicationHelper
  def format_time_just_calendar(time)
    t = Time.now
    time.strftime "%B %d#{time.year != t.year ? ', %Y' : ''}"
  end
end
