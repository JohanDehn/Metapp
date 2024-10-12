# Metapp

The purpose of creating this app was to learn Elixir, Phoenix Liveview and
Docker containers. There is a lot of tutorials out there, but I find that most
are the missing the point on creating a simple, straightforward guidance.

The app gets weather data from Yr.no and their forecast API.
A weather symbol and current temperature are displayed in a webpage.
Includes both frontend and backend.

Everything is stripped down to a bare minimum.

The application is based on the Yr.no API, and their collection of
weather symbols.

[Yr.no Developers guide](https://developer.yr.no/)

[Yr.no Weather Icons](https://github.com/metno/weathericons)

This is not ment to be a complete, production ready application, for example
the code it written in such way that its not completely following the
Term of Service. This to keep the complexity at lowest possible level.
Please read the terms of service in case you intend to make a production ready
application.

[Yr.no Terms of service](https://developer.yr.no/doc/TermsOfService/)

## How to run the application

To start the application

```text
$cd ./src/metapp
$sudo docker-compose up --build ./src/metapp
```

Access the application using any browser

```text
http://localhost:4000/weather
```

There are alternatives to check if the application works
Reach the Phoenix "hello world" page use following url.

```text
http://localhost:4000
```

A static version of the metapp were a icon and message is displayed.

```text
http://localhost:4000/metui
```

## Things I learned about Docker

Dockerfile and docker-compose are easiest to place in the root of your
application. This facilitates the building of the application.

You should use a Dockerfile and a docker-compose.

- Dockerfile sets up the container
- docker-compose.yaml orchestrates one or more containers

Then run your app with docker-compose commands.

### Docker - Commands Quick List

|CLI command  | Action |
|-|-|
|sudo docker-compose up | Starts container |
|sudo docker-compose up --build | Builds container and starts |
|sudo docker-compose down | Stops container |

## Things I Learned About Elixir Liveview in Docker

If you run a Phoenix app, the connection port will be set to 127.0.0 .
(localhost). This will result in being unable to connect to the web server as it is bound to the loopback interface in the container.

See the file `<app directory>/config/dev.exs`

By default, it is set to localhost. In a Docker container, this becomes the container's localhost, which cannot be accessed from your host machine.

```elixir
config :metApp, MetappWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
```

Change it to 0.0.0.0 so the app listens on all interfaces in the container.
Then you can access the app via <http://localhost:4000/> on your host machine.

```elixir
config :metApp, MetappWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
```

## Phoenix - How to create a new app

In a directory, run the command.
No ecto means opting out of database connection.
Live should be included automatically.

```text
mix phx.new <app name> --no-ecto
```

### How the Phoenix Concept Works

This page describes the process, the name is somewhat misleading (in my opinion).

[Link to tutorial](https://hexdocs.pm/phoenix/request_lifecycle.html)

This is the path conceptually from right to left,

```text
web browser -> router -> controller -> view -> uses an HTML template
```

Everything starts with the "router", which takes in the request from the
browser. Here is an example of how the router redirects to a destination,
the homepage.

|Browser Address  | Verb | Path |
|-|-|-|
|<http://localhost:4000> | GET | / |
|<http://localhost:4000/hello> | GET | /hello |
|<http://localhost:4000/hello/world> | GET | /hello/world |

The router points to a "controller" which is an Elixir module that
contains "actions" which are Elixir functions.

The controller, in turn, points to a view which is the presentation layer
which uses a HTML template.

### How to create a static page

This is a page where no data will change during the display of the page.

#### Step 1: How to add a new route

In this file, you will find the router, where you add a new entry to add a
new page.

```text
/lib/metapp_Web/router.ex
```

In the "scope" block, add a "get "/..." line.
In this code block, we add code,

```elixir
"get "/metui", MetuiController, :index"
```

The code after the change.

```elixir  
scope "/", MetappWeb do
  pipe_through :browser

  get "/", PageController, :home
  get "/metui", MetuiController, :index
end
```

#### Step 2: How to add a new controller

A new file is added in the following path, the name follows a convention but has
no actual connection to the function chain.

```text
/lib/metapp_Web/controllers/metui_controller.ex
```

It is the content of the file that connects to the router. In the router, the
name "MetuiController" is used, and we use the same name here in
the module definition. This is what links the router with the controller.

```elixir
defmodule MetappWeb.MetuiController do
  use MetappWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
```

The core of this action is

```elixir
render(conn, :index)
```

It is responsible for rendering a view, an "index" template.
So Phoenix expects that there is a file named

```text
metui_html.ex
```

#### Step 3: How to create a View

The view is the part responsible for rendering.

First, create a file named similarly to the others.

```text
/lib/metapp_web/metui_html.ex
```

In this file, add the code that points to your HTML template.
HTML templates are placed in a directory that you create yourself and should be
prefixed with the same name as the controller and view file.
In the example, everything is named "metui".

"metui_html" is a directory that you create yourself.

```text
/lib/metapp_web/controllers/metui_html
```

In this directory, create a file named
index.html.heex

"Index" because you point to it via your previous files, "html" because it is an
HTML file, and "heex" because it is an HTML + Eex file. Eex stands for
Elixir extension, and it allows us to embed Elixir in our HTML code.

```text
/lib/metapp_web/controllers/metui_html/index.html.heex
```

Example content

```html
<section>
  <h2>Hello World, from Phoenix!</h2>
</section>
```

Note that it is not a complete page but a part of a page.
There are layouts that you use.

### Step 4: How to Serve Images

You need to place the images in a directory called static

```text
src/metapp/priv/static/images/<directory with images>
```

On the website, add the img tag and point it to the images directory, which is
automatically pointed to by Plug to the priv directory.

[Doc: Plug.static](https://hexdocs.pm/plug/Plug.Static.html)

```html
  <img src="images/weather/svg/fair_day.svg" alt="Fair Day Weather Icon">
```

Then make sure the endpoint config has following setting fo the static path.

```text
src/metapp/lib/metapp_web/controllers/endpoint.ex
```

```elixir
only: MetappWeb.static_paths()
```

#### Notes on Filtering of statics

```text
src/metapp/lib/metapp_web/controllers/endpoint.ex
```

Check the line with "only:"

```elixir
  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :metapp,
    gzip: false,
    # only: MetappWeb.static_paths()
    only: ~w(assets fonts images favicon.ico robots.txt)
```

On the website, add the img tag and point it to the images directory, which is
automatically pointed to by Plug to the priv directory.
[Doc: Plug.static](https://hexdocs.pm/plug/Plug.Static.html)

```html
  <img src="images/weather/svg/fair_day.svg" alt="Fair Day Weather Icon">
```

"only" is a filter that matches against resources in the priv directory and
returns only what is within the parentheses. You could narrow it down to just
serving "images" if only the images should be displayed.

```elixir
only: ~w(assets fonts images favicon.ico robots.txt)
```

[Doc: Plug.static](https://hexdocs.pm/plug/Plug.Static.html)

### How to create a dynamic page

Create a page where you can change the icon with a form and build a backend that
fetches the current weather from Yr.no on command and when the website is
opened.

#### Step 1: Create a new route

The first thing to add is a live route that you access with, i.e., it does not
point to your static route.

Add following line to the router code.

```text
src/metapp/config/config.exs
```

```elixir
live "/weather", WeatherLive
```

So it looks like this when done

```elixir
  scope "/", MetappWeb do
    pipe_through :browser

    live "/weather", WeatherLive
    get "/", PageController, :home
    get "/metui", MetuiController, :index
  end
```

Access the new route by following url,

```text
localhost:4000/weather
```

Note that Copilot suggests adding an import. In later versions of Phoenix,this
is included in a code block at the bottom of the router, so you do not need to
add it.

```elixir
import Phoenix.LiveDashboard.Router
```

At the end of the file, you will find this section that now contains the import.

```elixir
 # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:metapp, :dev_routes) do

    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MetappWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
```

#### Step 2: Create Directory

Create a directory named live.

```text
./lib/metapp_web/live/
```

Note that the static page will be alongside the dynamic page.

#### Step 3: Create the middleware file

```text
./lib/metapp_web/live/weather_live.ex
```

In the "live" directory, create a file named `weather_live.ex`.
This acts as middleware for the webpage that is displayed.
The term middleware is used here to indicate that it functions as a backend for the HTML part of the webpage, but it should not be confused with the actual backend responsible for making requests to the Yr.no API.
One could argue that it is a controller and I might agree.
However the guideance does not place it file in the controller folder which can be confusing.

In this file, you mainly need the definition and the "mount" function.

The "handle_event" function is extended to handle an event "select_icon", which
is a drop-down where you can choose one of three images to display.

```elixir
defmodule MetappWeb.WeatherLive do
  use MetappWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, icon: "fair_day.svg")}
  end

  def handle_event("select_icon", %{"icon" => icon}, socket) do
    {:noreply, assign(socket, :icon, icon)}
  end
end
```

#### Step 4: Create the HTML Template

In the "live" directory, create a file named `weather_live.html.heex`.
This is the webpage that will be displayed.

```text
./lib/metapp_web/live/weather_live.html.heex
```

File content,

```html
<section style="display: flex; justify-content: flex-start; align-items: center; height: 100vh; flex-direction: column; padding-top: 20px;">
  <style>
    #weather-icon {
      width: 200px;
      height: 200px;
    }
    #weather-info {
      padding-top: 20px; /* Adjust the padding as needed */
      text-align: center;
    }
  </style>
  <div>
    <form phx-change="select_icon">
      <select name="icon">
        <option value="fair_day.svg">Fair Day</option>
        <option value="rain.svg">Rain</option>
        <option value="cloudy.svg">Cloudy</option>
      </select>
    </form>
  </div>
  <div>
    <img id="weather-icon" src={"images/weather/svg/#{@icon}"} alt="Weather Icon">
  </div>
</section>
```

#### Frontend: How it fits together

When you switch options in the dropdown, it is connected
from the form with a `phx-change` which is the event,
and the variable for the selection is `icon`.

This is the basic event chain that is executed when an object on the website
is manipulated down to middleware that fetches a resource and presents
it on the website.

```html
<form phx-change="select_icon">
   <select name="icon">
```

This is handled by the middleware script that is connected.

`select_icon`-event triggers when a selection has been made.
`icon` contains the selection made by the user.
The value in icon is forwarded to the connection of `img`,
which has the same name `{@icon}`.

```elixir
def handle_event("select_icon", %{"icon" => icon}, socket) do
  {:noreply, assign(socket, :icon, icon)}
end
```

Here is the result tag.

```html
 <img id="weather-icon" src={"images/weather/svg/#{@icon}"} alt="Weather Icon">
```

### Step 5: Prepare the backend

Here, the function is presented to fetch a value from a backend with a button
on the website. For simplicity, the backend presented will not contain any code
to contact an API but will only return a filename of the icon to be displayed.
This is so that we first understand the components of the event chain.

Analogy:
Imagine a stone being dropped into a pond; the stone sinks, and bubbles from the
bottom rise to the surface.
Similarly, the user's button press will sink down through the layers until the
bottom is reached in the backend, and the bubbles, the result, move up towards
the surface, meaning the website.

```text
weather_api.ex <=> weather_live.ex <=> weather_live_html.heex
```

The button in the HTML file generates a phx-click, which calls the function
"fetch_weather" in the file "weather_live.ex".

=> The stone starts to sink,

```html
<div>
  <img id="weather-icon" src={"images/weather/svg/#{@icon}"} alt="#{@icon}">
</div>
<div>
  <button id="weather-button" phx-click="fetch_weather" >Fetch Weather</button>
</div>
```

This event is captured by the function in "weather_live.ex".
Here, we call the function "get_weather_data" which returns
a tuple with `{:ok, weather_data}`.

`weather_data` contains only the name of the icon I want to display.
=> The stone continues to sink.

```elixir
def handle_event("fetch_weather", _params, socket) do
   
    case WeatherAPI.get_weather_data() do
      {:ok, weather_data} ->
        {:noreply, assign(socket, :icon, weather_data)}
      {:error, error} ->
        {:noreply, assign(socket, :error, error)}
    end

end
```

This is the function that now returns a tuple with the name of the SVG that I
want to display. The full backend code will be presented it its own section in
this document.

! The return of an static value here is just for learning purposes
to understand the core function and and the event chain.

```elixir bubbles up
def get_weather_data() do

    {:ok, "snow.svg"}

end
```

This now bubbles up to the calling function and makes an
assign to the socket, which is essentially the list of objects that liveview
keeps track of, and when a value in a "key" changes, the value in the DOM in the
HTML file is updated. If the function returns :error, it is handled by liveview
and the error message is printed in the view.

```elixir
def handle_event("fetch_weather", _params, socket) do
   
    case WeatherAPI.get_weather_data() do
      {:ok, weather_data} ->  
        {:noreply, assign(socket, :icon, weather_data)}
      {:error, error} ->
        {:noreply, assign(socket, :error, error)}
    end

end
```

### Step 6: Backend API

The backend consists of an API call to YR.no where weather data for a given
location is requested. This forms the data for the presentation layer.

#### File Structure

To build a backend, you create it in its own file, which then becomes a backend
to the live file of the website, which in practice is also a backend.

The flow is as follows:

api.ex -> live.ex -> html.heex

In the application, the decision was made to place all files in the
live directory. This is to provide context.

src/lib/live
      weather_api.ex
      weather_live.ex
      weather_live.html.heex

Details:

weather_api.ex

  This file contains the call to Yr.no, i.e., it is a backend.

weather_live.ex

  This file contains events for the HTML file, i.e., middleware.

weather_live.html.heex

  This file contains the frontend and HTML code for the presentation layer.

#### Backend koden

This is the full code to fetch weather data for a location using yr.no.

```text
./lib/metapp_web/live/weather_api.ex
```

```elixir
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
```

#### Backend: How it fits together

The first part involves setting up the request with a URL and a header when the
function is called from our middleware.

This is the call to the `get_weather_data` function from the middleware.

```text
./lib/metapp_web/live/weather_live.ex
```

```elixir
def handle_event("fetch_weather", _params, socket) do
   
    case WeatherAPI.get_weather_data() do
      {:ok, weather_data} ->  
        {:noreply, assign(socket, :icon, weather_data)}
      {:error, error} ->
        {:noreply, assign(socket, :error, error)}
    end

end
```

Which in turn runs the `get_weather_data` function in the backend file.
First, the header is set up.

```text
./lib/metapp_web/live/weather_live.ex
```

```elixir
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
```

The call to the API is then made using a library, HTTPoison.
What is returned is a relatively large JSON object.

```elixir
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, decoded_body} ->
```

To extract the data, we use get_in() which performs pattern matching to extract
the value from the key that holds the temperature and icon.

```elixir
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

```

Detailed explanation:

Pattern Matching with case:

The case expression is used to match the structure of the timeseries variable.
If timeseries is a non-empty list, it matches the pattern [first | _], where
first is the head (first element) of the list, and _ is the tail
(remaining elements, which are ignored).

Extracting Data:

If the pattern matches, it calls get_in/2 on first to navigate through nested
maps and extract the value associated with the key path
["data", "instant", "details", "air_temperature"].
get_in/2 is a function that retrieves a value from a nested data structure
(like a map) given a list of keys.

Error Handling:

If timeseries does not match the pattern
(i.e., it is an empty list or not a list), the code returns the string "error".
Example

Assume timeseries is defined as follows:

The case expression matches [first | _] with first being the first map in the
list.
get_in(first, ["data", "instant", "details", "air_temperature"]) retrieves the
value 22.5.

If timeseries were an empty list:

The case expression would not match [first | _] and would return "error".
Summary
This code is designed to safely extract the air temperature from a timeseries
data structure, handling the case where the data might be missing or malformed
by returning an error string.

```elixir
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
```
