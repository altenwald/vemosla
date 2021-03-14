defmodule Vemosla.FeaturesTest do
  use Vemosla.DataCase

  alias Vemosla.Features

  describe "features" do
    alias Vemosla.Features.Feature

    @valid_attrs %{description: "some description", title: "some title", votes: 42}
    @update_attrs %{description: "some updated description", title: "some updated title", votes: 43}
    @invalid_attrs %{description: nil, title: nil, votes: nil}

    def feature_fixture(attrs \\ %{}) do
      {:ok, feature} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Features.create_feature()

      feature
    end

    test "list_features/0 returns all features" do
      feature = feature_fixture()
      assert Features.list_features() == [feature]
    end

    test "get_feature!/1 returns the feature with given id" do
      feature = feature_fixture()
      assert Features.get_feature!(feature.id) == feature
    end

    test "create_feature/1 with valid data creates a feature" do
      assert {:ok, %Feature{} = feature} = Features.create_feature(@valid_attrs)
      assert feature.description == "some description"
      assert feature.title == "some title"
      assert feature.votes == 42
    end

    test "create_feature/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Features.create_feature(@invalid_attrs)
    end

    test "update_feature/2 with valid data updates the feature" do
      feature = feature_fixture()
      assert {:ok, %Feature{} = feature} = Features.update_feature(feature, @update_attrs)
      assert feature.description == "some updated description"
      assert feature.title == "some updated title"
      assert feature.votes == 43
    end

    test "update_feature/2 with invalid data returns error changeset" do
      feature = feature_fixture()
      assert {:error, %Ecto.Changeset{}} = Features.update_feature(feature, @invalid_attrs)
      assert feature == Features.get_feature!(feature.id)
    end

    test "delete_feature/1 deletes the feature" do
      feature = feature_fixture()
      assert {:ok, %Feature{}} = Features.delete_feature(feature)
      assert_raise Ecto.NoResultsError, fn -> Features.get_feature!(feature.id) end
    end

    test "change_feature/1 returns a feature changeset" do
      feature = feature_fixture()
      assert %Ecto.Changeset{} = Features.change_feature(feature)
    end
  end
end
