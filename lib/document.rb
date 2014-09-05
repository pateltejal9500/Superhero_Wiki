require 'active_record'
class Document < ActiveRecord::Base
  def author
    Author.find_by({id: self.author_id})
  end
end