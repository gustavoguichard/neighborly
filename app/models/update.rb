class Update < ActiveRecord::Base
  extend CatarseAutoHtml

  belongs_to :user
  belongs_to :project
  has_many :notifications, dependent: :destroy

  validates_presence_of :user_id, :project_id, :comment, :comment_html
  #remove all whitespace from the start of the line so auto_html won't go crazy
  before_save -> {self.comment = comment.gsub(/^[^\S\n]+/, "")}

  catarse_auto_html_for field: :comment, video_width: 560, video_height: 340

  scope :for_non_contributors, -> { where('not exclusive') }

  def update_number
    self.project.updates.where('id <= ?', self.id).count
  end

  def email_comment_html
    auto_html(comment) do
      html_escape map: {
        '&' => '&amp;',
        '>' => '&gt;',
        '<' => '&lt;',
        '"' => '"'
      }
      redcarpet markdown_options: { autolink: true, filter_html: true, link_attributes: { target: :blank }, hard_wrap: true }
    end
  end

  def notify_contributors
    project.subscribed_users.each do |user|
      Notification.notify_once(
        :updates,
        user,
        {update_id: self.id, user_id: user.id},
        {
          project: project,
          project_update: self,
          origin_email: project.user.email,
          origin_name: project.user.display_name
        }
      )
    end
  end

end
