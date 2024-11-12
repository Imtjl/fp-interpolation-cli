defmodule InterpolationCli.InputHandler do
  @moduledoc """
  Модуль для обработки входного потока данных. Сохраняет точки и отправляет их
  в модуль интерполяции, как только имеется достаточно данных.
  """

  use GenServer

  # API
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_point(x, y) do
    GenServer.cast(__MODULE__, {:add_point, {x, y}})
  end

  # Callbacks
  @impl true
  def init(_) do
    {:ok, []}
  end

  @impl true
  def handle_cast({:add_point, point}, state) do
    new_state = [point | state] |> Enum.sort_by(fn {x, _y} -> x end)

    # Передаём последние две точки для интерполяции
    if length(new_state) >= 2 do
      last_two_points = Enum.take(new_state, -2)
      InterpolationCli.LinearInterpolator.interpolate(last_two_points)
    end

    {:noreply, new_state}
  end
end
