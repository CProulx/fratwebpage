class Photo < ActiveRecord::Base
  belongs_to :album
  has_attached_file :image, :styles => {:large => "600x600", :medium => "300x300>", :thumb => "120x120>" }
  
  attr_accessible :image
  scope :in_order, :order => "album_order"

  before_destroy :last_photo_check
  def last_photo_check
    if self.album.photos.count == 1
        errors.add(:base, "cannot delete last image in album")
        return false
    end
    return true
  end
end
