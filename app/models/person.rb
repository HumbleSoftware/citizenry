class Person < ActiveRecord::Base
  attr_protected :user_id
  has_paper_trail :ignore => [:user_id]
  acts_as_taggable_on :tags, :technologies

  sortable

  require 'open-uri'
  has_attached_file :photo, :styles => { :medium => '220x220#', :thumb => '48x48#' }, :url => "/system/:attachment/:id/:style/:safe_filename"

  attr_accessor :photo_import_url
  before_validation do
    if self.photo_import_url.present?
      io = open(URI.parse(self.photo_import_url))
      def io.original_filename; base_uri.path.split('/').last; end

      self.photo = io if io.original_filename.present?
    end
  end

  belongs_to :user

  has_many :project_memberships
  has_many :projects, :through => :project_memberships

  has_many :group_memberships
  has_many :groups, :through => :group_memberships

  has_many :employments
  has_many :companies, :through => :employments

  validates_presence_of :name

  before_save :attach_to_matching_user

  scope :claimed, where('user_id IS NOT null')
  scope :unclaimed, where('user_id IS null')

  private

  def matching_user
    @matching_user ||= Authentication.where( :provider => self.imported_from_provider,
                                             :uid => self.imported_from_id ).first.try(:user)
  end

  def attach_to_matching_user
    if self.user.nil? && matching_user.present?
      self.user = matching_user
    end
  end
end





# == Schema Information
#
# Table name: people
#
#  id                        :integer(4)      not null, primary key
#  email                     :string(255)
#  twitter                   :string(255)
#  url                       :string(255)
#  bio                       :text
#  created_at                :datetime
#  updated_at                :datetime
#  user_id                   :integer(4)
#  name                      :string(255)
#  imported_from_provider    :string(255)
#  imported_from_id          :string(255)
#  location                  :string(255)
#  photo_file_name           :string(255)
#  photo_content_type        :string(255)
#  photo_file_size           :integer(4)
#  photo_updated_at          :datetime
#  reviewed                  :boolean(1)      default(FALSE)
#  imported_from_screen_name :string(255)
#

