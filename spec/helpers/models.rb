class User < MotionPrime::BaseModel
  attributes :id, :name, :age, :created_at
end

class Plane < MotionPrime::BaseModel
  attributes :id, :name, :age
end

class Listing < MotionPrime::BaseModel
  attribute :id
  attribute :name
end

class Todo < MotionPrime::BaseModel
  attribute :id
  attribute :title
  bag :items
end

class TodoItem < MotionPrime::BaseModel
  attribute :id
  attribute :completed
  attribute :text
end

class Page < MotionPrime::BaseModel
  attribute :id
  attribute :text
  attribute :index
end

class Animal < MotionPrime::BaseModel
  attribute :id
  attribute :name
end

class Autobot < MotionPrime::BaseModel
  attribute :id
  attribute :name
end

module CustomModule; end
class CustomModule::Car < MotionPrime::BaseModel
  attribute :id
  attribute :name
  attribute :created_at
end
Car = CustomModule::Car

def stub_user(name, age, created_at)
  user = User.new
  user.name = name
  user.age  = age
  user.created_at = created_at
  user
end

def documents_path
  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0]
end