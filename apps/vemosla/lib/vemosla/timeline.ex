defmodule Vemosla.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias Vemosla.Repo

  alias Vemosla.Contacts.Relation
  alias Vemosla.Timeline.{Comment, Post, Reaction}
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
    |> Repo.preload([:reactions, user: :profile, comments: [user: :profile]])
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

  def get_reaction_by_post_and_user(post_id, user_id) do
    Repo.get_by(Reaction, post_id: post_id, user_id: user_id)
  end

  def all_reactions_by_post(post_id) do
    reactions =
      Reaction
      |> Reaction.by_post_id(post_id)
      |> Repo.all()

    reactions =
      for {watched, reaction} <- Reaction.reactions() do
        %{
          "watched" => watched,
          "reaction" => reaction,
          "count" => Enum.count(
            reactions,
            & &1.reaction == reaction and
              &1.watched == watched
          )
        }
      end

    %{
      "post_id" => post_id,
      "reactions" => reactions
    }
  end

  def update_reaction(%Reaction{} = reaction, watched, reaction_text) do
    params = %{"reaction" => reaction_text, "watched" => watched}
    Reaction.changeset(reaction, params)
    |> Repo.update()
  end

  def create_reaction(user_id, post_id, watched, reaction) do
    params = %{"reaction" => reaction, "watched" => watched, "user_id" => user_id, "post_id" => post_id}
    Reaction.changeset(%Reaction{}, params)
    |> Repo.insert()
  end

  def list_comments_by_post(post_id) do
    Comment
    |> Comment.by_post_id(post_id)
    |> Repo.all()
  end

  def create_comment(user_id, post_id, comment) do
    params = %{"comment" => comment, "user_id" => user_id, "post_id" => post_id}
    Comment.changeset(%Comment{}, params)
    |> Repo.insert()
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
