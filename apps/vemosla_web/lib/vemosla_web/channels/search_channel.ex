defmodule VemoslaWeb.SearchChannel do
  use VemoslaWeb, :channel

  @wait_time 2

  @impl true
  def join("topic:search", payload, socket) do
    if authorized?(payload) do
      {:ok, assign(socket, :last_search, 0)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("search", "", socket), do: {:reply, {:ok, ""}, socket}
  def handle_in("search", search, socket) do
    now = DateTime.to_unix(DateTime.utc_now())
    if (socket.assigns[:last_search] < now) do
      size_pos = 2
      language = "es"
      page = 1
      include_adult = false
      case Vemosla.Movies.search_movie(search, size_pos, page, language, include_adult) do
        %{"results" => results} ->
          results =
            results
            |> Enum.map(& {&1["id"], &1["title"]})
            |> Enum.into(%{})

          {:reply, {:ok, results}, assign(socket, :last_search, now + @wait_time)}

        _ ->
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
