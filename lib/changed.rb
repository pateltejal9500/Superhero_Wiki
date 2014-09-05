require 'active_record'
class Change < ActiveRecord::Base
  def author
    Author.where({id: self.author_id})
  end
  def document
    Document.where({id: self.document_id})
  end
end