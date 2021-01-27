defmodule Vemosla.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias Vemosla.Repo

  alias Vemosla.Contacts.Relation
  alias Vemosla.Timeline.{Post, Reaction}
  alias Vemosla.Movies

  @doc """
  Returns a new post structure.

  ## Examples

      iex> new_post()
      %Post{}
  """
  def new_post() do
    %Post{reactions: [%Reaction{}]}
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  def list_my_posts(user_id, size_pos, language) do
    friends_query = Relation.friends_query(user_id)
    blocked_query = Relation.blocked_query(user_id)
    blockee_query = Relation.blockee_query(user_id)

    Post
    |> Post.list_my_timeline(friends_query, blocked_query, blockee_query, user_id)
    |> Repo.all()
    |> Repo.preload([:reactions, user: :profile])
    |> Enum.map(fn post ->
      case Movies.get_movie(post.movie_id, size_pos, language) do
        %{} = movie -> Map.put(post, :movie, movie)
        _ -> Map.put(post, :movie, nil)
      end
    end)
  end

  def list_want_watch(user_id) do
    Reaction
    |> Reaction.want_watch(user_id)
    |> Repo.all()
  end

  def count_want_watch(user_id) do
    Reaction
    |> Reaction.want_watch(user_id)
    |> Repo.aggregate(:count)
  end

  def list_watched(user_id) do
    Reaction
    |> Reaction.watched(user_id)
    |> Repo.all()
  end

  def count_watched(user_id) do
    Reaction
    |> Reaction.watched(user_id)
    |> Repo.aggregate(:count)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end
end
