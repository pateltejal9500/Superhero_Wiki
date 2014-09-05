require 'active_record'
class Change < ActiveRecord::Base
  def editedauthor
    Author.find_by({id: self.edited_id})
  end
  def document
    Document.where({id: self.document_id})
  end
end
