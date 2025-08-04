Rottenpotatoes::Application.routes.draw do
  resources :movies
  # map '/' to be a redirect to '/movies'
  root to: redirect('/movies')

  match 'search', to: 'movies#search_tmdb', via: [:get, :post], as: 'search_tmdb'
  post 'movies/add_movie', to: 'movies#add_movie', as: 'add_movie'
end
