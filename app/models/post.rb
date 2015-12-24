class AdditionalInfoContainsRequiredKeysValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:additional_info] << 'a splash_img is required of all posts' if record.additional_info[:splash_img].nil?
  end
end

class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  FILE_PATH = "posts/sources/"
  IMAGE_PATH = "/img/posts/"
  CATEGORIES = [:project, :thought, :review, :testing]
  ADDITIONAL_INFO_KEYS = [:splash_img, :subtitle]

  def self.path_to_post(path)
    path_arr = path.split('/').delete_if {|p| p.blank?}
    post = nil
    if path_arr.length == 3
      if path_arr[0] == 'posts'
        # We can now try the path
        results = Post.where(category: path_arr[1].singularize, file_path: path_arr[2])
        post = results[0] if results.exists?
      end
    end
    post
  end

  def self.cat_and_path_to_post(cat, path)
    results = Post.where(category: cat.singularize, file_path: path)
    results.exists? ? results[0] : nil
  end

  field :title, type: String
  field :tags, type: Array, default: []
  field :file_path, type: String
  field :category, type: Symbol, default: :testing
  field :additional_info, type: Hash, default: {}
  field :u_at, type: Time, default: ->{ Time.now }
  has_many :comments, dependent: :delete, autosave: true
  has_and_belongs_to_many :related_posts, class_name: "Post", autosave: true, after_add: :add_self_to_child

  validates :title, :file_path, presence: true
  validates :title, uniqueness: true
  validates_with AdditionalInfoContainsRequiredKeysValidator

  index title: 1

  def file_path
    FILE_PATH + category + "/" + super
  end

  def c_at
    created_at
  end

  def u_at
    time = File.mtime abs_file_path
    set u_at: time if self[:u_at] != time
    time
  end

  def get_image_path(key)
    "#{IMAGE_PATH}#{category}/#{self[:file_path]}/#{additional_info[key]}"
  end

  def category
    self[:category].to_s.pluralize
  end

  def to_param
    title
  end

  def add_self_to_child(post)
    post.related_posts << self unless post.related_posts.include? self
  end

  private

  def abs_file_path
    path = Rails.root.join 'app', 'views', FILE_PATH, category, "_#{self[:file_path]}.html.haml"
    return path if File.file? path
    path = Rails.root.join 'app', 'views', FILE_PATH, category, "_#{self[:file_path]}.html.erb"
    return path if File.file? path
    return nil
  end
end
