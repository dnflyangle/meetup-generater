require 'yaml'
module Meetupinator
  # class doco
  class InputFileReader
    def get_group_names(args)
      file_name = get_groups_filename(args)
      group_names = []
      File.open(file_name, 'rb') do |file|
        file.each_line { |line| group_names << line.strip }
      end
      group_names
    end

    def get_interal_events(args)
      events = []
      get_internal_events_filename(args).each do |file|
        event = YAML.load_file(file).first
        events << event
      end
      events
    end

    private

    def get_all_files(args)
      Dir[File.join(args, '**', '*')]
        .reject { |p| File.directory? p }
    end

    def get_groups_filename(args)
      get_all_files(args)
        .keep_if { |f| f.end_with?('.txt') }
        .first
    end

    def get_internal_events_filename(args)
      get_all_files(args)
        .keep_if { |f| f.end_with?('.yml') }
    end
  end
end
