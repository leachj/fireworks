class Task
  include DataMapper::Resource
 
  property :id,             Serial
  property :fired,        Boolean
  property :description,    Text
 
end
DataMapper.auto_upgrade!
