defmodule Vemosla.Contacts do
  @moduledoc """
  The Contacts context.
  """

  import Ecto.Query, warn: false
  alias Vemosla.Repo

  alias Vemosla.Contacts.Relation

  @doc """
  Returns the list of relations.

  ## Examples

      iex> list_relations()
      [%Relation{}, ...]

  """
  def list_relations do
    Repo.all(Relation)
    |> Repo.preload([:friend, :user])
  end

  def list_sent_invitations(user_id) do
    Relation
    |> Relation.user_id_query(user_id)
    |> Repo.all()
    |> Repo.preload(friend: :profile)
  end

  def list_received_invitations(user_id) do
    Relation
    |> Relation.friend_id_query(user_id)
    |> Relation.kind_query("pending")
    |> Repo.all()
    |> Repo.preload(user: :profile)
  end

  def list_blocked_users(user_id) do
    Relation
    |> Relation.friend_id_query(user_id)
    |> Relation.kind_query("blocked")
    |> Repo.all()
    |> Repo.preload(user: :profile)
  end

  def can_talk_together?(user1_id, user2_id) do
    Relation
    |> Relation.get_relationship(user1_id, user2_id)
    |> Repo.one()
  end

  @doc """
  Gets a single relation.

  Raises `Ecto.NoResultsError` if the Relation does not exist.

  ## Examples

      iex> get_relation!(123)
      %Relation{}

      iex> get_relation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_relation!(id) do
    Repo.get!(Relation, id)
    |> Repo.preload([:friend, :user])
  end

  def get_relation_by_email_and_user_id(email, user_id) do
    Relation
    |> Repo.get_by(friend_email: email, user_id: user_id)
    |> Repo.preload([:friend, :user])
  end

  @doc """
  Creates a relation.

  ## Examples

      iex> create_relation(%{field: value})
      {:ok, %Relation{}}

      iex> create_relation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_relation(attrs \\ %{}) do
    %Relation{}
    |> Relation.changeset(attrs)
    |> Repo.insert()
  end

  def invite(attrs, url) do
    attrs = Map.put(attrs, "kind", "pending")
    changeset = Relation.changeset(%Relation{}, attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create_invitation, changeset)
    |> Ecto.Multi.run(:send_email, fn _repo, changes ->
      changes[:create_invitation]
      |> Repo.preload(user: :profile)
      |> VemoslaMail.deliver_invitation_instructions(url)
    end)
    |> Repo.transaction()
  end

  @doc """
  Updates a relation.

  ## Examples

      iex> update_relation(relation, %{field: new_value})
      {:ok, %Relation{}}

      iex> update_relation(relation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_relation(%Relation{} = relation, attrs) do
    relation
    |> Relation.changeset(attrs)
    |> Repo.update()
  end

  defp create_or_update_relation(nil, kind, user, friend) do
    create_relation(%{
      "user_id" => user.id,
      "friend_id" => friend.id,
      "friend_email" => friend.email,
      "kind" => kind
    })
  end

  defp create_or_update_relation(relation, kind, _user, friend) do
    update_relation(relation, %{
      "friend_id" => friend.id,
      "kind" => kind
    })
  end

  def accept_invitation(nil, _friend), do: {:error, :notfound}
  def accept_invitation(_user, nil), do: {:error, :notfound}

  def accept_invitation(user, friend) do
    friend.email
    |> get_relation_by_email_and_user_id(user.id)
    |> create_or_update_relation("accepted", user, friend)

    user.email
    |> get_relation_by_email_and_user_id(friend.id)
    |> create_or_update_relation("accepted", friend, user)
  end

  def block_user(nil, _friend), do: {:error, :notfound}
  def block_user(_user, nil), do: {:error, :notfound}

  def block_user(user, friend) do
    friend.email
    |> get_relation_by_email_and_user_id(user.id)
    |> create_or_update_relation("blocked", user, friend)

    user.email
    |> get_relation_by_email_and_user_id(friend.id)
    |> delete_relation()
  end

  @doc """
  Deletes a relation.

  ## Examples

      iex> delete_relation(relation)
      {:ok, %Relation{}}

      iex> delete_relation(relation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_relation(nil), do: nil

  def delete_relation(%Relation{} = relation) do
    Repo.delete(relation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking relation changes.

  ## Examples

      iex> change_relation(relation)
      %Ecto.Changeset{data: %Relation{}}

  """
  def change_relation(%Relation{} = relation, attrs \\ %{}) do
    Relation.changeset(relation, attrs)
  end

  def contacts_sum(user_id) do
    Relation
    |> Relation.user_id_query(user_id)
    |> Relation.select_kind_group_and_count()
    |> Repo.all()
    |> Enum.reduce(%{}, &Map.merge/2)
  end
end
