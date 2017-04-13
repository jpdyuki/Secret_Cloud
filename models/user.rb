require 'json'
require 'sequel'

class User < Sequel::Model
  one_to_many :tfiles

  def to_json(options = {})
    JSON({
           type: 'user',
           id: id,
           attributes: {
             name: name
             #passwd: passwd
           }
         },
         options)
  end
end