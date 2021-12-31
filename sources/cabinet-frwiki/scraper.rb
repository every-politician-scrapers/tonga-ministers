#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'
require 'wikidata_ids_decorator'

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class MemberList
  class Members
    decorator RemoveReferences
    decorator WikidataIdsDecorator::Links

    def member_container
      noko.xpath('//table[.//th[contains(.,"Circonscription")]][1]//tr[td]')
    end
  end

  class Member
    field :wdid do
      tds[0].css('a/@wikidata').map(&:text).map(&:tidy).first
    end

    field :name do
      tds[0].css('a').map(&:text).first
    end

    field :position do
      tds[2].text.tidy.split(/(?=Ministre)/).map { |posn| posn.tidy.delete_suffix(',') }
    end

    private

    def tds
      noko.css('td')
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url).csv
