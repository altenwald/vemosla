defmodule VemoslaWeb.FeatureController do
  use VemoslaWeb, :controller

  alias Vemosla.Features
  alias Vemosla.Features.Feature

  def index(conn, _params) do
    features = Features.list_features()
    render(conn, "index.html", features: features)
  end

  def new(conn, _params) do
    changeset = Features.change_feature(%Feature{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"feature" => feature_params}) do
    user = conn.assigns.current_user
    feature_params = Map.put(feature_params, "user_id", user.id)
    case Features.create_feature(feature_params) do
      {:ok, _feature} ->
        conn
        |> put_flash(:info, "Característica creada correctamente.")
        |> redirect(to: Routes.feature_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    feature = Features.get_feature!(id)
    if feature.user_id == user.id do
      changeset = Features.change_feature(feature)
      render(conn, "edit.html", feature: feature, changeset: changeset)
    else
      conn
      |> put_flash(:error, "No tiene permiso para modificar la característica.")
      |> redirect(to: Routes.feature_path(conn, :index))
    end
  end

  def up(conn, %{"id" => id}) do
    case Features.vote_up(id) do
      {1, _feature} ->
        conn
        |> put_flash(:info, "Voto realizado correctamente.")
        |> redirect(to: Routes.feature_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "No se pudo votar la característica.")
        |> redirect(to: Routes.feature_path(conn, :index))
    end
  end

  def down(conn, %{"id" => id}) do
    case Features.vote_down(id) do
      {1, _feature} ->
        conn
        |> put_flash(:info, "Voto realizado correctamente.")
        |> redirect(to: Routes.feature_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "No se pudo votar la característica.")
        |> redirect(to: Routes.feature_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "feature" => feature_params}) do
    user = conn.assigns.current_user
    feature = Features.get_feature!(id)
    if feature.user_id == user.id do
      case Features.update_feature(feature, feature_params) do
        {:ok, _feature} ->
          conn
          |> put_flash(:info, "Característica actualizada correctamente.")
          |> redirect(to: Routes.feature_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", feature: feature, changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "No tiene permiso para modificar la característica.")
      |> redirect(to: Routes.feature_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    feature = Features.get_feature!(id)
    if feature.user_id == user.id do
      {:ok, _feature} = Features.delete_feature(feature)

      conn
      |> put_flash(:info, "Feature deleted successfully.")
      |> redirect(to: Routes.feature_path(conn, :index))
    else
      conn
      |> put_flash(:error, "No tiene permiso para eliminar la característica.")
      |> redirect(to: Routes.feature_path(conn, :index))
    end
  end
end
