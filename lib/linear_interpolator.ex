defmodule InterpolationCli.LinearInterpolator do
  @moduledoc """
  Module for linear interpolation. Receives a window of points and computes
  intermediate values with a given sampling frequency and step.
  """

  use GenServer

  # API
  def start_link(step) do
    GenServer.start_link(__MODULE__, step, name: __MODULE__)
  end

  def interpolate(points) do
    GenServer.cast(__MODULE__, {:interpolate, points})
  end

  def interpolate_sync(points) do
    GenServer.call(__MODULE__, {:interpolate_sync, points})
  end

  # Linear interpolation
  def perform_linear_interpolation(points, step) do
    [{x1, y1}, {x2, y2}] = points

    xs = Stream.iterate(x1, &(&1 + step)) |> Enum.take_while(&(&1 <= x2 + step))
    ys = Enum.map(xs, fn x -> y1 + (y2 - y1) / (x2 - x1) * (x - x1) end)
    res = Enum.zip(xs, ys)

    descr = """
    Linear (going from point #{Float.round(x1, 2)} with step #{step}, covering all input X (#{Float.round(x2, 2)} < #{Float.round(List.last(xs), 2)})):
    """

    {descr, res}
  end

  # Callbacks
  @impl true
  def init(step) do
    {:ok, step}
  end

  @impl true
  def handle_cast({:interpolate, points}, step) do
    {descr, res} = perform_linear_interpolation(points, step)
    InterpolationCli.OutputHandler.output(descr, res)
    {:noreply, step}
  end

  @impl true
  def handle_call({:interpolate_sync, points}, _from, step) do
    {descr, res} = perform_linear_interpolation(points, step)
    InterpolationCli.OutputHandler.output_sync(descr, res)
    {:reply, :ok, step}
  end
end
