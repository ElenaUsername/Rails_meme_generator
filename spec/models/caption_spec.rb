require 'rails_helper'

def test_caption_validation(url: url, text: text, expected_result_eq: expected_result_eq, expected_result_include: expected_result_include = nil, error_key: error_key = :text, type_field: type_field = 'simple')
  caption = Caption.new(url: url, text: text, type_field: type_field)
  expect(caption.valid?).to eq(expected_result_eq)
  expect(caption.errors[error_key]).to include(expected_result_include) if expected_result_include.present?
end

def test_caption_with_unique_name(url: url, text: text, unique_name: unique_name, expected_result_eq: expected_result_eq, expected_result_include: expected_result_include = nil, error_key: error_key = :text, type_field: type_field = 'simple')
  caption = Caption.new(url: url, text: text, unique_name: unique_name, type_field: type_field)
  expect(caption.valid?).to eq(expected_result_eq)
  expect(caption.errors[error_key]).to include(expected_result_include) if expected_result_include.present?
end

RSpec.describe Caption, type: :model do
  context 'caption validation' do
    it 'is valid with valid attributes' do
      test_caption_validation(url: 'https://example.com/image.jpg', text: 'This is a valid test', expected_result_eq: true)
    end

    it 'is invalid without a url' do
      test_caption_validation(url: nil, text: 'Hello', expected_result_eq: false)
    end

    it 'is invalid without text' do
      test_caption_validation(url: 'https://example.com/image.jpg', text: nil, expected_result_eq: false)
    end

    it 'is invalid without a url and shows error' do
      test_caption_validation(url: nil, text: 'Hello', expected_result_eq: false, expected_result_include: "can't be blank", error_key: :url)
    end

    it 'is invalid without text and shows error' do
      test_caption_validation(url: 'https://example.com/image.jpg', text: nil, expected_result_eq: false, expected_result_include: "can't be blank", error_key: :text)
    end

    it 'is invalid if text is longer than 266 characters' do
      test_caption_validation(url: 'https://example.com/image.jpg', text: 'a' * 267, expected_result_eq: false, expected_result_include: "is too long (maximum is 266 characters)", error_key: :text)
    end
  end

  describe '#url_points_to_valid_image_type' do
    it 'is valid with a .png URL' do
      test_caption_with_unique_name(url: 'https://site.com/avatar.png', text: 'Valid test', unique_name: 'unique_name_1', expected_result_eq: true)
    end

    it 'is invalid with a .pdf URL' do
      test_caption_with_unique_name(url: 'https://site.com/document.pdf', text: 'Invalid test', unique_name: 'unique_name_2', expected_result_eq: false, expected_result_include: "must point to a valid image (jpg, jpeg, png, gif, webp)", error_key: :url)
    end

    it 'is invalid with a completely broken/malformed URL' do
      test_caption_with_unique_name(url: 'not-a-valid-url', text: 'Invalid test', unique_name: 'unique_name_3', expected_result_eq: false, expected_result_include: "is not a valid URL", error_key: :url)
    end

    it 'is valid with an image URL that has query parameters and no extension' do
      test_caption_with_unique_name(
        url: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS8Pok87YcbWNcbOs5tMkvEpwuH7Y49rYluWBDb0FAGqQ&s=10',
        text: 'Valid query-string image',
        unique_name: 'unique_name_4',
        expected_result_eq: true
      )
    end
  end
end
