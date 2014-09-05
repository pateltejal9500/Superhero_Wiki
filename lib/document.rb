require 'active_record'
class Document < ActiveRecord::Base
  def author
    Author.find_by({id: self.author_id})
  end
  def edited
    Author.find_by({id: self.edited_id})
  end
  # def wikipedial_html_string
  #    HTTParty.get("www.wikipedia.com/#{name}")

  # end

  # def blah
  # end
end

# doc = Document.all.first
# doc.blah
#puts Document.all.first.wikipedia_html_string

#document = Document.find_by(name: "Captain America")
#puts document.wikipedia_html_string
