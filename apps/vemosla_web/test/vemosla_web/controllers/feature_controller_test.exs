defmodule VemoslaWeb.FeatureControllerTest do
  use VemoslaWeb.ConnCase

  alias Vemosla.Features

  @create_attrs %{description: "some description", title: "some title", votes: 42}
  @update_attrs %{description: "some updated description", title: "some updated title", votes: 43}
  @invalid_attrs %{description: nil, title: nil, votes: nil}

  def fixture(:feature) do
    {:ok, feature} = Features.create_feature(@create_attrs)
    feature
  end

  describe "index" do
    test "lists all features", %{conn: conn} do
      conn = get(conn, Routes.feature_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Features"
    end
  end

  describe "new feature" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.feature_path(conn, :new))
      assert html_response(conn, 200) =~ "New Feature"
    end
  end

  describe "create feature" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.feature_path(conn, :create), feature: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.feature_path(conn, :show, id)

      conn = get(conn, Routes.feature_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Feature"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.feature_path(conn, :create), feature: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Feature"
    end
  end

  describe "edit feature" do
    setup [:create_feature]

    test "renders form for editing chosen feature", %{conn: conn, feature: feature} do
      conn = get(conn, Routes.feature_path(conn, :edit, feature))
      assert html_response(conn, 200) =~ "Edit Feature"
    end
  end

  describe "update feature" do
    setup [:create_feature]

    test "redirects when data is valid", %{conn: conn, feature: feature} do
      conn = put(conn, Routes.feature_path(conn, :update, feature), feature: @update_attrs)
      assert redirected_to(conn) == Routes.feature_path(conn, :show, feature)

      conn = get(conn, Routes.feature_path(conn, :show, feature))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, feature: feature} do
      conn = put(conn, Routes.feature_path(conn, :update, feature), feature: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Feature"
    end
  end

  describe "delete feature" do
    setup [:create_feature]

    test "deletes chosen feature", %{conn: conn, feature: feature} do
      conn = delete(conn, Routes.feature_path(conn, :delete, feature))
      assert redirected_to(conn) == Routes.feature_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.feature_path(conn, :show, feature))
      end
    end
  end

  defp create_feature(_) do
    feature = fixture(:feature)
    %{feature: feature}
  end
end
