FactoryBot.define do
  factory :caption do
    url { "https://example.com/image.jpg" }
    text { "MyString" }
    kind { "simple" }
    caption_url { nil }
    type_field { nil }
    color { nil }
    start_color { nil }
    end_color { nil }
    filter { nil }
  end
end
