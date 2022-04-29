#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    REMAP = {
      'Minister of Foreign Affairs & Tourism' => [ 'Minister of Foreign Affairs', 'Minister of Tourism' ]
    }

    def name
      Name.new(
        full:     noko.css('h5').text.tidy,
        prefixes: %w[Hon Rev. Dr.]
      ).short
    end

    def position
      noko.css('h6').text.tidy.split(/[,\&] (?=Minister)/).map(&:tidy).
        map { |posn| REMAP.fetch(posn, posn) }
    end
  end

  class Members
    def member_container
      noko.css('.item-page .col-md-3')
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
