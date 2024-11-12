defmodule InterpolationCli.LinearInterpolator do
  @moduledoc """
  Модуль для линейной интерполяции. Получает окно точек от InputHandler и 
  вычисляет промежуточные значения с заданной частотой дискретизации, затем 
  отправляет результаты в OutputHandler.
  """

  use GenServer

  # API
  def start_link(frequency) do
    GenServer.start_link(__MODULE__, frequency, name: __MODULE__)
  end

  def interpolate(points) do
    GenServer.cast(__MODULE__, {:interpolate, points})
  end

  # Callbacks
  @impl true
  def init(frequency) do
    {:ok, frequency}
  end

  @impl true
  def handle_cast({:interpolate, [{x1, y1}, {x2, y2}]}, frequency) do
    # Генерируем промежуточные точки
    step = (x2 - x1) / frequency
    xs = Enum.map(0..frequency, fn i -> x1 + i * step end)
    ys = Enum.map(xs, fn x -> y1 + (y2 - y1) / (x2 - x1) * (x - x1) end)
    results = Enum.zip(xs, ys)
    # Отправляем результаты в OutputHandler
    InterpolationCli.OutputHandler.output(results)
    {:noreply, frequency}
  end

  @impl true
  def handle_cast(_, state), do: {:noreply, state}
end
