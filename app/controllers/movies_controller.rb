class MoviesController < ApplicationController
  before_action :force_index_redirect, only: [:index]

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @movies = Movie.with_ratings(ratings_list, sort_by)
    @ratings_to_show_hash = ratings_hash
    @sort_by = sort_by
    # remember the correct settings for next time
    session['ratings'] = ratings_list
    session['sort_by'] = @sort_by
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  def search_tmdb
    if request.get?
      render 'search_tmdb' and return
    end
  
    title = params[:title]
    language = params[:language] == 'all' ? nil : params[:language]
    year = params[:release_year]
  
    if title.blank?
      flash[:warning] = 'Please fill in all required fields!'
      redirect_to search_tmdb_path and return
    end
  
    @movies = Movie.find_in_tmdb({ title: title, language: language, release_year: year })
  
    if @movies.blank?
      flash[:warning] = 'No movies found with given parameters!'
      redirect_to search_tmdb_path and return
    else
      render 'search_tmdb'
    end
  end

  def add_movie
    @movie = Movie.create!(
      title: params[:title],
      release_date: params[:release_date],
      rating: params[:rating],
      description: params[:overview]
    )
    flash[:success] = "#{@movie.title} was successfully added to RottenPotatoes."
    redirect_to movies_path
  end

  private

  def force_index_redirect
    return unless !params.key?(:ratings) || !params.key?(:sort_by)

    flash.keep
    url = movies_path(sort_by: sort_by, ratings: ratings_hash)
    redirect_to url
  end

  def ratings_list
    params[:ratings]&.keys || session[:ratings] || Movie.all_ratings
  end

  def ratings_hash
    ratings_list.to_h { |item| [item, "1"] }
  end

  def sort_by
    params[:sort_by] || session[:sort_by] || 'id'
  end
end
