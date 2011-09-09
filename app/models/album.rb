class Album < ActiveRecord::Base
  has_many :photos
  
  attr_writer :initial_photos, :photo_order
  attr_accessible :initial_photos, :name, :photo_order, :description
  
  validates_length_of :name, :minimum => 1
  
  
  before_save :store_initial_photos
  def store_initial_photos
    self.photos.destroy if self.photos
    @initial_photos.each{|ph|
      unless ph.blank?
        self.photos.build(:image => ph)
      end
    } unless @initial_photos.blank?
  end
  
  after_save :save_photo_order, :photo_cleanup
  def save_photo_order
    return if @photo_order.blank?
    @photo_order = @photo_order.split(",") if @photo_order.is_a?(String)
    @photo_collection = []

    @photo_order.each{|ph_id|
      @photo_collection << self.photos.find(ph_id) rescue nil
    }
    @photo_collection.each{|ph|
      ph.update_attribute(:album_order, @photo_order.index(ph.id.to_s))
    }
  end
    
  def photo_cleanup
    # Clean this function up. Its very very dirty... Btw I just Lost..
    return if @photo_order.nil?
    photos_for_deletion = self.photos.collect{|ph| ph unless (@photo_order.include?(ph.id.to_s) || ph.album_order.blank?) }
    return if photos_for_deletion.blank?
    photos_for_deletion.each{|photo|
      if photo
        photo.destroy
      end
    }
  end
  
  
  def cover_image
    self.photos.in_order.find(:first)
  end
  
  
  def photo_order
    self.photos.in_order.collect(&:id).join(",")
  end
  
  
end
