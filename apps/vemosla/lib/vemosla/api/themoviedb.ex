defmodule Vemosla.Api.Themoviedb do
  use Tesla
  use Memoize

  @default_language "es"

  plug(Tesla.Middleware.BaseUrl, "http://api.themoviedb.org")

  plug(Tesla.Middleware.Headers, [
    {"Content-type", "application/json; charset=utf-8"},
    {"Authorization", "Bearer #{api_key()}"}
  ])

  plug(Tesla.Middleware.JSON)

  defp api_key do
    Application.get_env(:vemosla, :themoviedb_token)
  end

  defmemo configuration(), expires_in: 24 * 3_600_000 do
    case get("/3/configuration") do
      {:ok, resp} -> resp.body
      {:error, _} = error -> error
    end
  end

  defmemo trending(size_pos, media_type \\ "all", window \\ "day", language \\ @default_language),
    expires_in: 3_600 do
    get("/3/trending/#{media_type}/#{window}", query: %{"language" => language})
    |> process_multi(size_pos, language)
  end

  defmemo similar_movies(id, size_pos, page \\ 1, language \\ @default_language),
    expires: 24 * 3_600_000 do
    get("/3/movie/#{id}/similar", query: %{"language" => language, "page" => page})
    |> process_movies(size_pos, language)
  end

  defmemo recommended_movies(id, size_pos, page \\ 1, language \\ @default_language),
    expires: 24 * 3_600_000 do
    get("/3/movie/#{id}/recommendations", query: %{"language" => language, "page" => page})
    |> process_movies(size_pos, language)
  end

  defmemo movie_alternative_title(id, country), expires: 24 * 3_600_000 do
    case get("/3/movie/#{id}/alternative_titles") do
      {:ok, %{body: %{"titles" => titles}}} ->
        Enum.find(titles, &(&1["iso_3166_1"] == country))
        |> case do
          nil -> nil
          %{"title" => title} -> title
        end

      {:ok, _resp} ->
        nil

      {:error, _error} ->
        nil
    end
  end

  defmemo tv_alternative_title(id, country), expires: 24 * 3_600_000 do
    case get("/3/tv/#{id}/alternative_titles") do
      {:ok, %{body: %{"titles" => titles}}} ->
        Enum.find(titles, &(&1["iso_3166_1"] == country))
        |> case do
          nil -> nil
          %{"title" => title} -> title
        end

      {:ok, _resp} ->
        nil

      {:error, _error} ->
        nil
    end
  end

  defmemo movie_credits(id, size_pos, language \\ @default_language), expires: 24 * 3_600_000 do
    case get("/3/movie/#{id}/credits", query: %{"language" => language}) do
      {:ok, %{body: %{"id" => id, "crew" => crew, "cast" => cast}}} ->
        %{
          "id" => id,
          "crew" => Enum.map(crew, &process_person(&1, size_pos, language)),
          "cast" => Enum.map(cast, &process_person(&1, size_pos, language))
        }

      {:error, _} = error ->
        error
    end
  end

  defmemo movie_images(id, size_pos, language \\ @default_language), expires: 24 * 3_600_000 do
    query = %{
      "language" => language,
      "include_image_language" => "#{language},en,null"
    }

    case get("/3/movie/#{id}/images", query: query) do
      {:ok, %{body: %{"id" => id, "backdrops" => backdrops, "posters" => posters}}} ->
        %{
          "id" => id,
          "backdrops" =>
            Enum.map(backdrops, fn backdrop ->
              url = path_to_url("backdrop", backdrop["file_path"], size_pos)
              Map.put(backdrop, "file_url", url)
            end),
          "posters" =>
            Enum.map(posters, fn poster ->
              url = path_to_url("poster", poster["file_path"], size_pos)
              Map.put(poster, "file_url", url)
            end)
        }

      {:error, _} = error ->
        error
    end
  end

  defmemo watch(id, country, size_pos), expires: 24 * 3_600_000 do
    case get("/3/movie/#{id}/watch/providers") do
      {:ok, %{body: %{"results" => %{^country => options}}}} ->
        rent =
          Enum.map(options["rent"], fn entry ->
            Map.put(entry, "logo_url", path_to_url("logo", entry["logo_path"], size_pos))
          end)

        buy =
          Enum.map(options["buy"], fn entry ->
            Map.put(entry, "logo_url", path_to_url("logo", entry["logo_path"], size_pos))
          end)

        flat =
          Enum.map(options["flatrate"], fn entry ->
            Map.put(entry, "logo_url", path_to_url("logo", entry["logo_path"], size_pos))
          end)

        %{
          "link" => options["link"],
          "flatrate" => flat,
          "rent" => rent,
          "buy" => buy
        }

      {:ok, _resp} ->
        {:error, :enocountry}

      {:error, _} = error ->
        error
    end
  end

  defmemo now_playing(size_pos, country, page \\ 1, language \\ @default_language),
    expires: 24 * 3_600_000 do
    query = %{
      "region" => country,
      "page" => page,
      "language" => language
    }

    get("/3/movie/now_playing", query: query)
    |> process_movies(size_pos, language)
  end

  defmemo get_movie(id, size_pos, language \\ @default_language), expires: 24 * 3_600_000 do
    get("/3/movie/#{id}", query: %{"language" => language})
    |> case do
      {:ok, %{body: body}} -> process_movie(body, size_pos, language)
      {:error, _} = error -> error
    end
  end

  defmemo get_tv(id, size_pos, language \\ @default_language), expires: 24 * 3_600_000 do
    get("/3/tv/#{id}", query: %{"language" => language})
    |> case do
      {:ok, %{body: body}} -> process_tv_show(body, size_pos, language)
      {:error, _} = error -> error
    end
  end

  def get_movie_genre(id, language \\ @default_language) do
    case get_movie_genres(language) do
      {:error, _} = error ->
        Memoize.invalidate(__MODULE__, :get_movie_genres)
        error

      genre ->
        genre[id]
    end
  end

  defmemo get_movie_genres(language \\ @default_language), expires_in: 24 * 3_600_000 do
    case get("/3/genre/movie/list", query: %{"language" => language}) do
      {:ok, resp} ->
        for %{"id" => id, "name" => name} <- resp.body["genres"], into: %{} do
          {id, name}
        end

      {:error, _} = error ->
        error
    end
  end

  def get_tv_genre(id, language \\ @default_language) do
    case get_tv_genres(language) do
      {:error, _} = error ->
        Memoize.invalidate(__MODULE__, :get_tv_genres)
        error

      genre ->
        genre[id]
    end
  end

  defmemo get_tv_genres(language \\ @default_language), expires_in: 24 * 3_600_000 do
    case get("/3/genre/tv/list", query: %{"language" => language}) do
      {:ok, resp} ->
        for %{"id" => id, "name" => name} <- resp.body["genres"], into: %{} do
          {id, name}
        end

      {:error, _} = error ->
        error
    end
  end

  def path_to_url(_type, nil, _size_pos), do: nil

  def path_to_url(type, path, size_pos) do
    cfg = configuration()
    size = Enum.at(cfg["images"]["#{type}_sizes"], size_pos)
    cfg["images"]["secure_base_url"] <> size <> path
  end

  def search(query, size_pos, page \\ 1, language \\ @default_language, include_adult \\ false) do
    get("/3/search/multi",
      query: %{
        "query" => query,
        "page" => page,
        "language" => language,
        "include_adult" => include_adult
      }
    )
    |> process_multi(size_pos, language)
  end

  defp process_multi({:ok, %{body: body}}, size_pos, language) do
    results =
      for result <- body["results"] do
        case result["media_type"] do
          "movie" -> process_movie(result, size_pos, language)
          "tv" -> process_tv_show(result, size_pos, language)
          "person" -> process_person(result, size_pos, language)
        end
      end

    put_in(body["results"], results)
  end

  defp process_multi({:error, _} = error, _size_pos, _language) do
    error
  end

  def search_tv(query, size_pos, page \\ 1, language \\ @default_language, include_adult \\ false) do
    get("/3/search/tv",
      query: %{
        "query" => query,
        "page" => page,
        "language" => language,
        "include_adult" => include_adult
      }
    )
    |> process_tv_shows(size_pos, language)
  end

  defp process_tv_shows({:ok, %{body: body}}, size_pos, language) do
    results =
      for result <- body["results"] do
        process_tv_show(result, size_pos, language)
      end

    put_in(body["results"], results)
  end

  defp process_tv_shows({:error, _} = error, _size_pos, _language) do
    error
  end

  defp process_tv_show(result, size_pos, language) do
    Map.merge(result, %{
      "genres" => Enum.map(result["genre_ids"], &get_tv_genre(&1, language)),
      "backdrop_url" => path_to_url("backdrop", result["backdrop_path"], size_pos),
      "poster_url" => path_to_url("poster", result["poster_path"], size_pos),
      "media_type" => "tv",
      "title" => result["name"],
      "original_title" => result["original_name"],
      "release_date" => result["first_air_date"],
      "adult" => false
    })
    |> Map.drop(["name", "first_air_date", "original_name"])
  end

  def search_person(
        query,
        size_pos,
        page \\ 1,
        language \\ @default_language,
        include_adult \\ false
      ) do
    get("/3/search/person",
      query: %{
        "query" => query,
        "page" => page,
        "language" => language,
        "include_adult" => include_adult
      }
    )
    |> process_people(size_pos, language)
  end

  defp process_people({:ok, %{body: body}}, size_pos, language) do
    results =
      for result <- body["results"] do
        process_person(result, size_pos, language)
      end

    put_in(body["results"], results)
  end

  defp process_people({:error, _} = error, _size_pos, _language) do
    error
  end

  defp process_person(result, size_pos, language) do
    Map.merge(result, %{
      "profile_url" => path_to_url("profile", result["profile_path"], size_pos),
      "media_type" => "person",
      "known_for" =>
        Enum.map(result["known_for"], fn
          %{"media_type" => "movie"} = movie -> process_movie(movie, size_pos, language)
          %{"media_type" => "tv"} = tv -> process_tv_show(tv, size_pos, language)
        end)
    })
  end

  def search_movie(
        query,
        size_pos,
        page \\ 1,
        language \\ @default_language,
        include_adult \\ false
      ) do
    get("/3/search/movie",
      query: %{
        "query" => query,
        "page" => page,
        "language" => language,
        "include_adult" => include_adult
      }
    )
    |> process_movies(size_pos, language)
  end

  defp process_movies({:ok, %{body: body}}, size_pos, language) do
    results =
      for result <- body["results"] do
        process_movie(result, size_pos, language)
      end

    put_in(body["results"], results)
  end

  defp process_movies({:error, _} = error, _size_pos, _language) do
    error
  end

  defp process_movie(result, size_pos, language) do
    Map.merge(result, %{
      "genres" => Enum.map(result["genre_ids"] || [], &get_movie_genre(&1, language)),
      "backdrop_url" => path_to_url("backdrop", result["backdrop_path"], size_pos),
      "poster_url" => path_to_url("poster", result["poster_path"], size_pos),
      "media_type" => "movie"
    })
  end
end
