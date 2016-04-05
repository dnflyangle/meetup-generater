module Meetupinator
  # doco
  class App
    def self.version
      'meetupinator v' + Meetupinator::VERSION
    end

    def self.retrieve_events(args = {})
      new.retrieve_events(args)
    end

    def self.format(args = {})
      new.format(args)
    end

    def retrieve_events(args)
      init_retrieve(args)
      retrieve_meetup_events(args)
      retrieve_internal_events(args)
    end

    def retrieve_meetup_events(args)
      group_names = @input_file_reader.get_group_names args[:input]
      events = @event_finder.extract_events(group_names, @api, args[:weeks])
      @event_list_file_writer.write events, args[:output]
    end

    def retrieve_internal_events(args)
      events = @input_file_reader.get_interal_events args[:input]
      @event_list_file_writer.write_internal_events events, args[:output]
    end

    def init_retrieve(args)
      @api = Meetupinator::MeetupAPI.new(args[:meetup_api_key])
      @input_file_reader = Meetupinator::InputFileReader.new
      @event_finder = Meetupinator::EventFinder.new
      @event_list_file_writer = Meetupinator::EventListFileWriter.new
    end

    def format(args)
      reader = Meetupinator::EventListFileReader.new
      formatter = Meetupinator::Formatter.new

      events = reader.read(args[:input])
      formatter.format(events, args[:template], args[:output])
    end
  end
end
