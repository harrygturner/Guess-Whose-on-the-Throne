require 'rest-client'
require 'net/http'
require 'open-uri'
require 'json'
require 'pry'

class Get
  def self.obtain_character(id = 1)
    character = RestClient.get("https://www.anapioficeandfire.com/api/characters/#{id}")
    character_hash = JSON.parse(character)
    character_hash
  end

  def self.symbol(id = 1)
    new_hash = {}
    self.obtain_character(id).each do |attr, value|
      if attr == "tvSeries" && value.first != ""
        new_hash[:series_debut] = value.first
        new_hash[:final_appearance] = value.last
        new_hash[:number_of_appearances] = value.count
      elsif attr == "tvSeries"
        new_hash[:number_of_appearances] = 0
      elsif attr == "playedBy"
        new_hash[:played_by] = value.first
      else
      new_hash[attr.to_sym] = value
      end
    end
    new_hash
  end

  def self.dead?(id = 1)
    character_hash = self.symbol(id)
    character_hash.each do |attr, value|
      if attr == :died && value == ""
        character_hash[attr] = false
      elsif attr == :died
        character_hash[attr] = true
      end
    end
  end

  def self.spouse?(id = 1)
    character_hash = self.dead?(id)
    character_hash.each do |attr, value|
      if attr == :spouse && value != ""
        character_hash[:spouse] = JSON.parse(RestClient.get(value))["name"]
      elsif attr == :spouse
        character_hash[:spouse] = "SINGLE"
      end
      character_hash
    end
  end

  def self.allegiances?(id = 1)
    allegiance_array = []
    character_hash = self.spouse?(id)
    character_hash.each do |attr, value|
      if attr == :allegiances && value.count == 0
        character_hash[attr] = ["No Allegiances"]
      elsif attr == :allegiances
        value.each do |allegiance|
          allegiance_array << JSON.parse(RestClient.get(allegiance))["name"]
        end
        character_hash[attr] = allegiance_array
      end
    end
    character_hash
  end

  def self.books?(id = 1)
    book_array = []
    character_hash = self.allegiances?(id)
    character_hash.each do |attr, value|
      if attr == :books && value.first == [""]
        character_hash[attr] = "Not in a book"
      elsif attr == :books
        value.each do |book|
          book_array << JSON.parse(RestClient.get(book))["name"]
        end
        character_hash[attr] = book_array
      end
    end
    character_hash
  end

end
