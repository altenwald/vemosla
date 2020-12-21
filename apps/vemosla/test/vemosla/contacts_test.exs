defmodule Vemosla.ContactsTest do
  use Vemosla.DataCase

  alias Vemosla.Contacts

  describe "relations" do
    alias Vemosla.Contacts.Relation

    @valid_attrs %{kind: "some kind"}
    @update_attrs %{kind: "some updated kind"}
    @invalid_attrs %{kind: nil}

    def relation_fixture(attrs \\ %{}) do
      {:ok, relation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contacts.create_relation()

      relation
    end

    test "list_relations/0 returns all relations" do
      relation = relation_fixture()
      assert Contacts.list_relations() == [relation]
    end

    test "get_relation!/1 returns the relation with given id" do
      relation = relation_fixture()
      assert Contacts.get_relation!(relation.id) == relation
    end

    test "create_relation/1 with valid data creates a relation" do
      assert {:ok, %Relation{} = relation} = Contacts.create_relation(@valid_attrs)
      assert relation.kind == "some kind"
    end

    test "create_relation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_relation(@invalid_attrs)
    end

    test "update_relation/2 with valid data updates the relation" do
      relation = relation_fixture()
      assert {:ok, %Relation{} = relation} = Contacts.update_relation(relation, @update_attrs)
      assert relation.kind == "some updated kind"
    end

    test "update_relation/2 with invalid data returns error changeset" do
      relation = relation_fixture()
      assert {:error, %Ecto.Changeset{}} = Contacts.update_relation(relation, @invalid_attrs)
      assert relation == Contacts.get_relation!(relation.id)
    end

    test "delete_relation/1 deletes the relation" do
      relation = relation_fixture()
      assert {:ok, %Relation{}} = Contacts.delete_relation(relation)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_relation!(relation.id) end
    end

    test "change_relation/1 returns a relation changeset" do
      relation = relation_fixture()
      assert %Ecto.Changeset{} = Contacts.change_relation(relation)
    end
  end
end
