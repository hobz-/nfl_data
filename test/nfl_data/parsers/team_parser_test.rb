require 'test_helper'

describe TeamParser do
  before do
    @parser = TeamParser.new
  end

  after do
    @parser = nil
  end

  it 'should know the correct base url' do
    @parser.base_url.must_equal "http://www.nfl.com/standings?category=league&split=Overall&season="
  end

  describe 'get_by_year' do
    it 'should get all the teams for year without schedule' do
      VCR.use_cassette('teams_without_schedule') do
        @parser.get_by_year(2014, false).count.must_equal 32
      end
    end

    it 'should get all the teams for year with schedule' do
      VCR.use_cassette('teams_with_schedule') do
        @parser.get_by_year(2014, true).count.must_equal 32
      end
    end
  end
end
