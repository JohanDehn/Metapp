defmodule MetappWeb.WeatherLive do
  use MetappWeb, :live_view
  alias MetappWeb.WeatherAPI

  # This is the initial mount function that is called when the live view is mounted
  # Mounted means that the live view is loaded in the browser.
  def mount(_params, _session, socket) do
    case WeatherAPI.get_weather_data() do
      {:ok, icon, temperature} ->
        # This is a keyword list
        {:ok, assign(socket, icon: icon, temperature: temperature, error: nil)}
        # This is sama as above but using a mapp
        #{:noreply, assign(socket, %{icon: icon, temperature: temperature})}
      {:error, error} ->
        {:error, assign(socket, :error, error)}
    end
    #{:ok, assign(socket, icon: "fair_day.svg", temperature: "21", error: nil)}
  end

  # This is the handle_event function that is called when an event is triggered.
  # In this case, the event is triggered when the user selects an icon.
  def handle_event("select_icon", %{"icon" => icon}, socket) do
    {:noreply, assign(socket, :icon, icon)}
  end

  def handle_event("fetch_weather", _params, socket) do
    case WeatherAPI.get_weather_data() do
      {:ok, icon, temperature} ->
        # This is a keyword list
        {:noreply, assign(socket, icon: icon, temperature: temperature)}
        # This is samasas above but using a mapp instead
        #{:noreply, assign(socket, %{icon: icon, temperature: temperature})}
      {:error, error} ->
        {:noreply, assign(socket, :error, error)}
    end
  end

end
