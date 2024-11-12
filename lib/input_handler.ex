defmodule InterpolationCli.InputHandler do
  @moduledoc """
  Handles the input stream of data points, storing them and passing them to interpolation as required.
  """

  use GenServer

  # API
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_point(x, y) do
    GenServer.cast(__MODULE__, {:add_point, {x, y}})
  end

  def input_finished do
    GenServer.cast(__MODULE__, :input_finished)
  end

  # Callbacks
  @impl true
  def init(_) do
    {:ok, []}
  end

  @impl true
  def handle_cast({:add_point, point}, state) do
    new_state = [point | state] |> Enum.sort_by(fn {x, _y} -> x end)

    algorithms = Application.get_env(:interpolation_cli, :algorithms, [:linear])

    if :linear in algorithms and length(new_state) >= 2 do
      last_two_points = Enum.take(new_state, -2)
      InterpolationCli.LinearInterpolator.interpolate(last_two_points)
    end

    # Trigger Lagrange interpolation with at least four points
    if :lagrange in algorithms and length(new_state) >= 4 do
      InterpolationCli.LagrangeInterpolator.interpolate(new_state)
    end

    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:input_finished, state) do
    IO.puts("Input processing finished.")
    {:noreply, state}
  end
end
