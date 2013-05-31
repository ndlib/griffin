require 'faker'

FactoryGirl.define do

  factory :request do
    needed_by Date.today + 2.weeks
    sequence(:title) { |n| "Request Title #{n}" }
    course_id "adsfdasadfs"
    requestor_netid "netid"
    association(:item)
    note { Faker::Lorem.paragraph }
  end

  trait :new do
    workflow_state "new"
  end

  trait :inprocess do
    workflow_state "inprocess"
  end

  trait :available do
    workflow_state "available"
  end

  trait :book do
    association(:item, factory: :item_book)
  end

  trait :book_chapter do
    association(:item, factory: :item_book_chapter)
  end

  trait :journal_file do
    association(:item, factory: :item_journal_file)
  end

  trait :journal_url do
    association(:item, factory: :item_journal_url)
  end

  trait :video do
    association(:item, factory: :item_video)
  end

  trait :audio do
    association(:item, factory: :item_audio)
  end

end
