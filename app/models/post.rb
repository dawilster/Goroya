class Post < ActiveRecord::Base
  attr_accessible :name, :content, :gist_id
end
