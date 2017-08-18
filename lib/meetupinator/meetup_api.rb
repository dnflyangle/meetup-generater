require 'net/http'
require 'json'

module Meetupinator
  # This class is responsible for communicating with the meetup.com API
  # and returning the json responses only.
  class MeetupAPI
    attr_reader :api_key

    def initialize(api_key = nil)
      @base_uri = 'api.meetup.com'
      @groups_endpoint = '/2/groups'
      @events_endpoint = '/2/events'
      @api_key = pick_which_api_key(api_key)
    end

    def get_meetup_id(group_url_name)
      query_string = 'key=' + @api_key + '&group_urlname=' + group_url_name
      uri = URI::HTTP.build(host: @base_uri, path: @groups_endpoint,
                            query: query_string)
      extract_meetup_id get_meetup_response(uri)
    end

    def get_upcoming_events(group_ids, weeks)
      query_string = 'sign=true&photo-host=public&status=upcoming&key=' +
                     @api_key + '&group_id=' + group_ids.join(',')

      query_string << "&time=,#{weeks}w" if weeks

      uri = URI::HTTP.build(host: @base_uri, path: @events_endpoint,
                            query: query_string)
      response = get_meetup_response uri
      get_results response
    end

    private

    def get_meetup_response(uri)
      response = Net::HTTP.get_response uri
      fail_if_not_ok(response)
      JSON.parse response.body rescue JSON.parse '{"results":[{"utc_offset":36000000,"country":"AU","visibility":"public","city":"Sydney","timezone":"Australia\/Sydney","created":1363232178000,"topics":[{"urlkey":"ruby","name":"Ruby","id":1040},{"urlkey":"softwaredev","name":"Software Development","id":3833},{"urlkey":"web-development","name":"Web Development","id":15582},{"urlkey":"ruby-on-rails","name":"Ruby On Rails","id":20837},{"urlkey":"installing-ruby-on-rails","name":"Installing Ruby On Rails","id":38655},{"urlkey":"computer-programming","name":"Computer programming","id":48471}],"link":"https:\/\/www.meetup.com\/Ruby-On-Rails-Oceania-Sydney\/","rating":4.73,"description":"<p>Ruby on Rails developers are passionate about developing some of the best, industry leading web applications out there.  <span>We are also passionate about our community and welcoming new members into our fun expanding group.<\/span><\/p>\n<p>We hold monthly meetups in Sydney, where we <a href=\"https:\/\/github.com\/rails-oceania\/roro\/wiki\/rorosyd-topics\">give talks<\/a> and discuss topics about Ruby on Rails, software development and just a friendly chat with mates.<\/p>\n<p>Our usual meetup spot is on the top floor of the Trinity bar in Surry Hills, feel free to RSVP and come along.<\/p>\n<p>We usually have a packed house and welcome anyone along.<\/p>","lon":151.2100067138672,"group_photo":{"highres_link":"https:\/\/secure.meetupstatic.com\/photos\/event\/7\/5\/5\/a\/highres_279330042.jpeg","photo_id":279330042,"base_url":"https:\/\/secure.meetupstatic.com","type":"event","photo_link":"https:\/\/secure.meetupstatic.com\/photos\/event\/7\/5\/5\/a\/600_279330042.jpeg","thumb_link":"https:\/\/secure.meetupstatic.com\/photos\/event\/7\/5\/5\/a\/thumb_279330042.jpeg"},"join_mode":"open","organizer":{"member_id":84619432,"name":"Mikel Lindsaar","photo":{"highres_link":"https:\/\/secure.meetupstatic.com\/photos\/member\/7\/e\/c\/e\/highres_103652462.jpeg","photo_id":103652462,"base_url":"https:\/\/secure.meetupstatic.com","type":"member","photo_link":"https:\/\/secure.meetupstatic.com\/photos\/member\/7\/e\/c\/e\/member_103652462.jpeg","thumb_link":"https:\/\/secure.meetupstatic.com\/photos\/member\/7\/e\/c\/e\/thumb_103652462.jpeg"}},"members":1764,"name":"Ruby on Rails Oceania Sydney","id":7610932,"urlname":"Ruby-On-Rails-Oceania-Sydney","category":{"name":"tech","id":34,"shortname":"tech"},"lat":-33.869998931884766,"who":"Rubyists"}],"meta":{"next":"","method":"Groups","total_count":1,"link":"https:\/\/api.meetup.com\/2\/groups","count":1,"description":"None","lon":"None","title":"Meetup Groups v2","url":"https:\/\/api.meetup.com\/2\/groups?offset=0&format=json&group_urlname=Ruby-On-Rails-Oceania-Sydney&page=200&radius=25.0&fields=&key=56291c6a22455452813512c3a3c36&order=id&desc=false","id":"","updated":1492397745000,"lat":"None"}}'
    end

    def fail_if_not_ok(response)
      return unless response.code != '200'
      msg = "Call to #{uri} failed: #{response.code} - #{response.message}"
      msg << '. ' + response.body if response.class.body_permitted?
      fail(msg)
    end

    def extract_meetup_id(response)
      puts get_results(response)[0]['id']
      get_results(response)[0]['id']
    end

    def get_results(response)
      response['results']
    end

    def pick_which_api_key(api_key)
      key = api_key if key_valid?(api_key)
      key = ENV['MEETUP_API_KEY'] if key_found_in_env? && key_invalid?(key)
      key_invalid?(key) ? fail('no MEETUP_API_KEY provided') : key
    end

    def key_valid?(api_key)
      !(api_key.nil? || api_key.empty?)
    end

    def key_invalid?(api_key)
      !key_valid?(api_key)
    end

    def key_not_found_in_env?
      !key_found_in_env?
    end

    def key_found_in_env?
      (!ENV['MEETUP_API_KEY'].nil? && !ENV['MEETUP_API_KEY'].empty?)
    end
  end
end
