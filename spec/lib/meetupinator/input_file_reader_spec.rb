require 'fakefs/spec_helpers'
require 'spec_helper'
require 'meetupinator/input_file_reader'

describe Meetupinator::InputFileReader do
  include FakeFS::SpecHelpers::All

  let(:input_file_dir) { '/tmp/input/file/location' }
  let(:file_name) { input_file_dir + '/input_file.txt' }
  let(:group_names) { %w(some_group another_group more_groups) }

  let(:yml_file_name) { 'input.yml' }
  let(:yml_input) do
    "---
      -
        group_name: ThoughtWorks
        event_name: Software shokunin community
        day_of_week: Thursday
        start_date: 7/04/2016
        start_time: 6:00 PM
        end_time: 9:00 PM
        event_url: http://thoughtworks.com
        repeat: weekly
        end_date: 7/05/2016"
  end

  let(:expected_output) do
    [
      { 'group_name' => 'ThoughtWorks',
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

  def clean_up(file)
    File.delete(file) if File.exist?(file)
  end

  after do
    clean_up file_name
    clean_up yml_file_name
  end

  describe '#group_names' do
    before do
      # need to make dir for fakefs
      FileUtils.mkdir_p(input_file_dir)
      File.open(file_name, 'wb') do |file|
        group_names.each { |items| file << items + "\n" }
      end
    end

    it { expect(Meetupinator::InputFileReader.group_names(file_name)).to eq(group_names) }
  end

  describe '#interal_events' do
    before do
      File.write(yml_file_name, yml_input)
    end

    it { expect(Meetupinator::InputFileReader.interal_events(yml_file_name)).to eq(expected_output) }
  end
end
