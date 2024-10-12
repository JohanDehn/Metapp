# lib/my_app/weather_api.ex
defmodule MetappWeb.WeatherAPI do
  @moduledoc """
  A module to fetch weather data from a public API.
  """

  @api_url "https://api.met.no/weatherapi/locationforecast/2.0/mini?lat=55.4&lon=13.5"

  def get_weather_data() do

    url = "#{@api_url}"
    headers = [
      {"user-agent", "AlphaTest/0.1"},
      {"if-modified-since", "Thu, 01 Jan 1970 00:00:00 GMT"}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, decoded_body} ->
            timeseries = get_in(decoded_body, ["properties", "timeseries"])

            # Ensure timeseries is a list and has at least one element
            temperature =
              case timeseries do
                [first | _] -> get_in(first, ["data", "instant", "details", "air_temperature"])
                _ -> "error"
              end
            icon =
              case timeseries do
                [first | _] -> get_in(first, ["data", "next_1_hours", "summary", "symbol_code"])
                _ -> "error"
              end
            icon = "#{icon}.svg"
            # Return to calling function
            {:ok, icon, temperature}

          {:error, reason} ->
            IO.puts(reason)
            icon = "error"
            temperature = "error"
            # Return to calling function
            {:ok, icon, temperature}
        end
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.puts(status_code)
        {:error, "Failed to fetch weather data. Status code: #{status_code}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts(reason)
        {:error, "Failed to fetch weather data. Reason: #{reason}"}
    end

  end
end
