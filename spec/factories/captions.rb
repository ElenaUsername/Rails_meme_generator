FactoryBot.define do
  factory :caption do
    url { "https://example.com/image.jpg" }
    text { "MyString" }
    caption_url { nil }
    type_field { "simple" }
    color { nil }
    start_color { nil }
    end_color { nil }
    filter { nil }
  end
end
