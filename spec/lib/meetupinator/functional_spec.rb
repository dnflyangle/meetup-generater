require 'vcr_setup'
require 'spec_helper'
require 'meetupinator/cli'

# Joe: I know I've written another functional test as well but,
# i'll leave this one in here too.
# Sometime it helps to write the output to disk especially for debugging.

describe 'meetupinator' do
  # In an ideal world, we'd use FakeFS here.
  # Unfortunately, FakeFS and VCR don't coexist very well.
  # Something like the solution proposed in https://github.com/vcr/vcr/issues/234 could work,
  # but for the time being we can just use temp files instead.
  let(:input_file) { Dir::Tmpname.make_tmpname(['input', '.txt'], nil) }
  let(:output_file) { Dir::Tmpname.make_tmpname(['output', '.csv'], nil) }

  let(:expected_csv_output) do
    [
      {
        group_name: 'The Melbourne Node.JS Meetup Group',
        event_name: 'Feb meetup: io.js & ES6 & more',
        day_of_week: 'Wednesday',
        date: '4/02/2015',
        start_time: '6:30 PM',
        end_time: '9:30 PM',
        event_url: 'http://www.meetup.com/MelbNodeJS/events/219976432/'
      },
      {
        group_name: 'Ruby and Rails Melbourne',
        event_name: 'Hack Night',
        day_of_week: 'Tuesday',
        date: '10/02/2015',
        start_time: '6:00 PM',
        end_time: '9:00 PM',
        event_url: 'http://www.meetup.com/Ruby-On-Rails-Oceania-Melbourne/events/219387827/'
      },
      {
        group_name: 'Ruby and Rails Melbourne',
        event_name: 'Ruby on Rails InstallFest',
        day_of_week: 'Thursday',
        date: '19/02/2015',
        start_time: '6:30 PM',
        end_time: '9:00 PM',
        event_url: 'http://www.meetup.com/Ruby-On-Rails-Oceania-Melbourne/events/219051382/'
      },
      {
        group_name: 'Ruby and Rails Melbourne',
        event_name: 'Melbourne Ruby',
        day_of_week: 'Wednesday',
        date: '25/02/2015',
        start_time: '6:00 PM',
        end_time: '9:00 PM',
        event_url: 'http://www.meetup.com/Ruby-On-Rails-Oceania-Melbourne/events/219387830/'
      }
    ]
  end

  def clean_up(file)
    File.delete(file) if File.exist?(file)
  end

  before do
    Dir.chdir('..')
    FileUtils.rm_rf('test')
    clean_up output_file
    create_input_file
  end

  after do
    Dir.chdir('..')
    FileUtils.rm_rf('test')
    clean_up output_file
  end

  context 'when given minimal correct arguments' do
    it 'will fetch and save events for all meetups' do
      VCR.use_cassette('getevents_functional_test') do
        puts input_file
        args = ['getevents', '-i', Dir.pwd, '-o', output_file, '-k', '1234']
        expect { Meetupinator::CLI.start(args) }.to match_stdout("Output written to #{output_file}")
        expect(read_output_file).to eq(expected_csv_output)
      end
    end
  end

  context 'when given the --version argument' do
    before { stub_const('Meetupinator::VERSION', '9.23') }

    it 'returns the version' do
      args = ['--version']
      expect { Meetupinator::CLI.start(args) }.to match_stdout('meetupinator v9.23')
    end
  end

  context 'when given the -v argument' do
    before { stub_const('Meetupinator::VERSION', '9.23') }

    it 'returns the version' do
      args = ['-v']
      expect { Meetupinator::CLI.start(args) }.to match_stdout('meetupinator v9.23')
    end
  end

  def create_input_file
    group_names = ['MelbNodeJS', 'Ruby-On-Rails-Oceania-Melbourne']
    FileUtils.mkdir_p('test')
    Dir.chdir('test')
    File.open(input_file, 'wb') do |file|
      group_names.each { |name| file << name + "\n" }
    end
  end

  def read_output_file
    actual_csv_output = nil
    File.open output_file do |body|
      csv = CSV.new(body, headers: true, header_converters: :symbol, converters: :all)
      actual_csv_output = csv.to_a.map(&:to_hash)
    end
    actual_csv_output
  end
end
