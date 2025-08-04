require 'rails_helper'

if RUBY_VERSION>='2.6.0'
  if Rails.version < '5'
    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        # hack to avoid MonitorMixin double-initialize error:
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        initialize
      end
    end
  else
    puts "Monkeypatch for ActionController::TestResponse no longer needed"
  end
end

describe MoviesController do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end
    
    # it 'calls the model method that performs TMDb search' do
    #   fake_results = [double('movie1'), double('movie2')]
    #   expect(Movie).to receive(:find_in_tmdb).with('hardware').
    #     and_return(fake_results)
    #   get :search_tmdb, {:title => 'hardware'}
    # end

    # it 'calls the model method that performs TMDb search' do
    #   expect(Movie).to receive(:find_in_tmdb).with('hardware').
    #     and_return(@fake_results)
    #   get :search_tmdb, {:title => 'hardware'}
    # end
  end

  describe 'after valid search' do

    before :each do
      @fake_results = [
        {
          title: 'Hardware',
          overview: 'Sci-fi thriller',
          release_date: '1990-01-01',
          rating: 'R',
          tmdb_id: 1
        }
      ]
      allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
      get :search_tmdb, { title: 'hardware', language: 'en', release_year: nil }
    end

    it 'selects the Search Results template for rendering' do
      expect(response).to render_template('search_tmdb')
    end

    it 'makes the TMDb search results available to that template' do
      expect(assigns(:movies)).to eq(@fake_results)
    end
  end
end