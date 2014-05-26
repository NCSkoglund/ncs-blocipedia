# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :wiki do
    title "MyString"
    body "MyText that is twenty characters long"
  end
end

FactoryGirl.modify do
  factory :wiki do 
    description "MyDescription"

    #automatically create an associated tag
    tags { |a| [a.association(:tag)] }
  end
end
