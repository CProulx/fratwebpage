class WikiAlias < ActiveRecord::Base
  belongs_to :wiki_page
  
  validates_uniqueness_of :name, :message => "must be unique"
  validates :wiki_page, :presence => true
  validate :alias_check
  
  def alias_check
    m = WikiPage.find(:first, :conditions => ["id <> ? AND (name LIKE ? or name LIKE ?)",self.id,"%#{self.name}%","#{self.name}%"])
    if m
      self.errors.add(:name, "cannot be a subset or superset of another wiki page's name or alias (see: #{m.name})")
    else
      a = WikiAlias.find(:first, :conditions => ["id <> ? AND (name LIKE ? or name LIKE ?)",self.id,"%#{self.name}%","#{self.name}%"])
      self.errors.add(:name, "cannot be a subset or superset of another wiki page's name or alias (see: #{a.name})") if a
    end
  end
  
  
end
