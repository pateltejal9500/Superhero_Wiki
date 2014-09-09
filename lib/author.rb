require 'active_record'
class Author < ActiveRecord::Base
  def document
    Document.where({author_id: self.id})
  end
end