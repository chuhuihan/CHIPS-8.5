class Movie < ActiveRecord::Base
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  def self.find_in_tmdb(search_terms)
    raise ArgumentError, 'Missing title' if search_terms[:title].blank?
  
    base_url = 'https://api.themoviedb.org/3/search/movie'
    query = {
      api_key: 'f068f6491c378ee992b992df4c971ba8',
      query: search_terms[:title],
      language: search_terms[:language],
      year: search_terms[:release_year]
    }.compact
  
    response = Faraday.get(base_url, query)
    parsed = JSON.parse(response.body)
  
    parsed['results'].map do |movie|
      {
        tmdb_id: movie['id'],
        title: movie['title'],
        release_date: movie['release_date'],
        overview: movie['overview'],
        rating: 'R'
      }
    end
  end  

end
