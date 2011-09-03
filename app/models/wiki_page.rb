class WikiPage < ActiveRecord::Base
  belongs_to :author, :class_name => "Member"
  belongs_to :last_edit_by, :class_name => "Member"
  has_many :wiki_files, :dependent => :destroy
  has_many :wiki_aliases, :dependent => :destroy
  
  attr_accessible :name, :content, :wiki_files_accessor, :files_to_delete, :wiki_alias_accessor
  scope :sorted_by_name, :order => "name"
  
  validates_uniqueness_of :name, :message => "must be unique"
  validate :alias_validation

  def alias_validation
    begin
      self.wiki_aliases #for migration
    rescue Exception => e
      return
    rescue Mysql::Error => e
      return
    end
    
    
    
    m = WikiPage.find(:first, :conditions => ["id <> ? AND (name LIKE ? or name LIKE ?)",self.id,"%#{self.name}%","#{self.name}%"])
    if m
      self.errors.add(:name, "cannot be a subset or superset of another wiki page's name or alias (see: #{m.name})")
    else
      a = WikiAlias.find(:first, :conditions => ["id <> ? AND (name LIKE ? or name LIKE ?)",self.id,"%#{self.name}%","#{self.name}%"])
      self.errors.add(:name, "cannot be a subset or superset of another wiki page's name or alias (see: #{a.name})") if a
    end
    
    self.wiki_aliases.each{|a|
      a.errors.full_messages.each{|e| errors.add(:base, "#{a.name}: #{e}")} unless a.valid?
    }
  end
  
  before_create :check_last_edit
  def check_last_edit
    self.last_edit_by = self.author unless self.last_edit_by 
  end
  
  after_save :delete_files
  def delete_files
    self.wiki_files.select{|f| f[:delete]}.each(&:destroy) rescue nil
  end
  
  def linked_content
    cleaned_content = self.content.clone
    all = WikiPage.all
    all.delete(self)
    all.each{|w|
      w.name.sub!(/^THE\s|^A\s|^IF\s/i,"") #add regex to keep it to the front of the line and case insensitive
      w.name.strip!
    }
    
    all = all.collect{|w|  
      [{:name => w.name, :id => w.id}].concat(w.wiki_aliases.collect{|wa| {:name => wa.name, :id => w.id}})
    }
    all.flatten!
    
    all = all.sort_by{|w| -w[:name].length}
    replace_markers = []
    all.each{|w| 
      name = w[:name].gsub(/\s/,"\\s")
      exp = /^#{name}|\s#{name}\s|#{name}$/i
      if cleaned_content =~ exp
        cleaned_content.gsub!(exp," <<#{replace_markers.length}>> ")
        replace_markers << "<a href='/wiki_pages/#{w[:id]}'>#{w[:name]}</a>"
      end
    }
    
    replace_markers.each_with_index{|m,index|
      cleaned_content.gsub!("<<#{index}>>", m)
    }
    cleaned_content
  end
  
  def wiki_files_accessor=(array)
    array = [array] unless array.is_a?(Array)
    array.each{|file|
      unless file.blank?
        self.wiki_files.build(:data => file)
      end
    }
  end
  
  def files_to_delete=(array)
    array = array.gsub(/\s/,"").split(",").reject(&:blank?).collect(&:to_i) if array.is_a?(String)
    unless array.blank?
      self.wiki_files.find(array).each{|d| d[:delete] = true}
    end
  end
  
  def wiki_alias_accessor=(array)
    self.wiki_aliases.destroy_all
    array.each{|a|
      self.wiki_aliases.build(:name => a, :wiki_page => self) unless a.blank?
    }
  end
  
end
