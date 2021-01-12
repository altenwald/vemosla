defmodule Vemosla.Movies do
  alias Vemosla.Api.Themoviedb

  defdelegate search_movie(query, size_pos, page, language, include_adult),
    to: Themoviedb

  defdelegate get_movie(id, size_pos, language),
    to: Themoviedb

end
