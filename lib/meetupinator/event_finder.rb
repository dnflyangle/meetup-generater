module Meetupinator
  # class def
  class EventFinder
    DAY = 60 * 60 * 24

    def extract_events(group_url_names, api, weeks)
      ids = group_url_names.map { |name| api.get_meetup_id name }

      api.get_upcoming_events(ids, weeks)
    end

    def filter_internal_events(events)
      events.keep_if { |event| }

    end

    private

    def get_start_of_week
      d = Time.now
      d -= DAY until d.monday?
      d
    end

    def get_end_of_week
      d = Time.now
      d += DAY until d.sunday?
      d
    end
  end
end
