# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tag do
    tag "MyString"
  end
end

#prevent validation conflicts
FactoryGirl.modify do
  factory :tag do    
    sequence(:tag) { |n| "person#{n}@example.com" }
  end
end
