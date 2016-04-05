require 'fakefs/spec_helpers'
require 'spec_helper'
require 'meetupinator/event_list_file_writer'

describe Meetupinator::EventListFileWriter do
  include FakeFS::SpecHelpers::All

  let(:file_name) { 'output.csv' }

  def clean_up
    File.delete(file_name) if File.exist?(file_name)
  end

  before { clean_up }

  after { clean_up }

  describe '#write' do
    let(:events) do
      [
        {
          'group' => { 'name' => 'The Society of Chocolate Eaters' },
          'name' => 'The Time When We Eat Chocolate',
          'time' => 142_355_160_000_0,
          'utc_offset' => 396_000_00,
          'duration' => 720_000_0,
          'event_url' => 'http://www.awesomemeetup.com/'
        }
      ]
    end

    let(:expected_csv_output) do
      [
        {
          group_name: 'The Society of Chocolate Eaters',
          event_name: 'The Time When We Eat Chocolate',
          day_of_week: 'Tuesday',
          date: '10/02/2015',
          start_time: '6:00 PM',
          end_time: '8:00 PM',
          event_url: 'http://www.awesomemeetup.com/'
        }
      ]
    end

    it 'writes the events to file' do
      subject.write events, file_name

      File.open file_name do |body|
        csv = CSV.new(body, headers: true, header_converters: :symbol,
                            converters: :all)
        actual_csv_output = csv.to_a.map(&:to_hash)
        expect(actual_csv_output).to eq(expected_csv_output)
      end
    end

    context 'when the event does not have a duration' do
      before do
        events[0].delete('duration')
        expected_csv_output[0][:end_time] = '9:00 PM'
      end

      # According to http://www.meetup.com/meetup_api/docs/2/events/,
      # if no duration is specified,
      # we can assume 3 hours.
      it 'writes the event to file assuming the duration is 3 hours' do
        subject.write events, file_name

        File.open file_name do |body|
          csv = CSV.new(body, headers: true, header_converters: :symbol,
                              converters: :all)
          actual_csv_output = csv.to_a.map(&:to_hash)
          expect(actual_csv_output).to eq(expected_csv_output)
        end
      end
    end
  end

  describe '#write_internal_events' do
    let(:interal_events) do
      [
        {
          'group_name' => 'ThoughtWorks',
          'event_name' => 'Software shokunin community',
          'day_of_week' => 'Thursday',
          'start_date' => '7/04/2016',
          'start_time' => '6:00 PM',
          'end_time' => '9:00 PM',
          'event_url' => 'http://thoughtworks.com',
          'repeat' => 'weekly',
          'end_date' => '7/05/2016'
        }
      ]
    end

    let(:expected_csv_output) do
      [
        {
          group_name: 'SydJS',
          event_name: 'SydJSzero: REDUX',
          day_of_week: 'Wednesday',
          date: '06/04/2016',
          start_time: '6:00 PM',
          end_time: '9:00 PM',
          event_url: 'http://www.sydjs.com/meetups'
        },
        {
          group_name: 'ThoughtWorks',
          event_name: 'Software shokunin community',
          day_of_week: 'Thursday',
          date: '7/04/2016',
          start_time: '6:00 PM',
          end_time: '9:00 PM',
          event_url: 'http://thoughtworks.com'
        }
      ]
    end

    before do
      CSV.open(file_name, 'wb') do |csv|
        csv << ['Group name', 'Event name', 'Day of week', 'Date',
                'Start time', 'End time', 'Event URL']
        csv << ['SydJS', 'SydJSzero: REDUX', 'Wednesday', '06/04/2016',
                '6:00 PM', '9:00 PM', 'http://www.sydjs.com/meetups']
      end
    end

    it 'append the event to the tail of given csv file' do
      subject.write_internal_events interal_events, file_name

      File.open file_name do |body|
        csv = CSV.new(body, headers: true, header_converters: :symbol,
                            converters: :all)
        actual_csv_output = csv.to_a.map(&:to_hash)
        expect(actual_csv_output).to eq(expected_csv_output)
      end
    end
  end
end
