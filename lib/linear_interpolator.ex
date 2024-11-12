defmodule InterpolationCli.LinearInterpolator do
  @moduledoc """
  Module for linear interpolation. Receives a window of points from InputHandler and
  computes intermediate values with a given sampling frequency and step, then sends results to OutputHandler.
  """

  use GenServer

  # API
  def start_link([frequency, step]) do
    GenServer.start_link(__MODULE__, {frequency, step}, name: __MODULE__)
  end

  def interpolate(points) do
    GenServer.cast(__MODULE__, {:interpolate, points})
  end

  def interpolate_sync(points) do
    GenServer.call(__MODULE__, {:interpolate_sync, points})
  end

  def perform_linear_interpolation(points, step) do
    [{x1, y1}, {x2, y2}] = points

    xs = Stream.iterate(x1, &(&1 + step)) |> Enum.take_while(&(&1 <= x2 + step))
    ys = Enum.map(xs, fn x -> y1 + (y2 - y1) / (x2 - x1) * (x - x1) end)
    res = Enum.zip(xs, ys)

    range_start = if is_integer(x1), do: x1 * 1.0, else: x1
    range_end = if is_integer(x2 + step), do: (x2 + step) * 1.0, else: x2 + step

    descr = """
    Линейная (идем от точки #{Float.round(range_start, 2)} с шагом #{step}, покрывая все введенные X (#{Float.round(range_end, 2)} < #{Float.round(x2, 2)})):
    """

    {descr, res}
  end

  # Callbacks
  @impl true
  def init({frequency, step}) do
    {:ok, %{frequency: frequency, step: step}}
  end

  @impl true
  def handle_cast({:interpolate, points}, state) do
    {descr, res} = perform_linear_interpolation(points, state.step)
    InterpolationCli.OutputHandler.output(descr, res)
    {:noreply, state}
  end

  @impl true
  def handle_call({:interpolate_sync, points}, _from, state) do
    {descr, res} = perform_linear_interpolation(points, state.step)
    InterpolationCli.OutputHandler.output_sync(descr, res)
    {:reply, :ok, state}
  end
end
