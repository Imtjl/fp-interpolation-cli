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
  def handle_cast({:interpolate, points}, frequency) do
    # Получаем последние две точки для интерполяции
    [{x1, y1}, {x2, y2}] = Enum.take(points, -2)

    # Шаг интерполяции
    step = 1.0

    # Диапазон интерполяции от x1 до x2 с заданным шагом
    xs = Stream.iterate(x1, &(&1 + step)) |> Enum.take_while(&(&1 <= x2 + step))
    ys = Enum.map(xs, fn x -> y1 + (y2 - y1) / (x2 - x1) * (x - x1) end)
    results = Enum.zip(xs, ys)

    # Форматированный вывод диапазона с округлением
    range_start = Float.round(x1, 2)
    range_end = Float.round(x2 + step, 2)

    IO.puts("")

    IO.puts(
      "Линейная (идем от точки #{range_start} с шагом #{step}, покрывая все введенные X (#{range_end} < #{Float.round(x2, 2)})):"
    )

    InterpolationCli.OutputHandler.output(results)

    {:noreply, frequency}
  end

  @impl true
  def handle_cast(_, state), do: {:noreply, state}
end
