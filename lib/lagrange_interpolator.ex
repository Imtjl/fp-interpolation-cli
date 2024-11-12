defmodule InterpolationCli.LagrangeInterpolator do
  @moduledoc """
  Module for Lagrange interpolation. Receives multiple points and computes
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

  # Lagrange interpolation
  defp perform_lagrange_interpolation(points, step) do
    points = Enum.take(points, -4)
    x_min = points |> hd() |> elem(0)
    x_max = points |> List.last() |> elem(0)

    xs =
      Stream.iterate(x_min, &(&1 + step))
      |> Enum.take_while(&(&1 <= x_max + step))

    ys =
      Enum.map(xs, fn x ->
        lagrange_value(points, x)
      end)

    res = Enum.zip(xs, ys)

    descr = """
    Lagrange (from point #{Float.round(x_min, 2)} with step #{step}, covering all input X (#{Float.round(x_max, 2)} < #{Float.round(List.last(xs), 2)})):
    """

    {descr, res}
  end

  defp lagrange_value(points, x) do
    Enum.reduce(points, 0.0, fn {x_i, y_i}, acc ->
      acc + y_i * basis_polynomial(points, x, x_i)
    end)
  end

  defp basis_polynomial(points, x, x_i) do
    Enum.reduce(points, 1.0, fn {x_j, _}, prod ->
      if x_i != x_j do
        prod * (x - x_j) / (x_i - x_j)
      else
        prod
      end
    end)
  end

  # Callbacks
  @impl true
  def init(step) do
    {:ok, step}
  end

  @impl true
  def handle_cast({:interpolate, points}, step) do
    {descr, res} = perform_lagrange_interpolation(points, step)
    InterpolationCli.OutputHandler.output(descr, res)
    {:noreply, step}
  end

  @impl true
  def handle_call({:interpolate_sync, points}, _from, step) do
    {descr, res} = perform_lagrange_interpolation(points, step)
    InterpolationCli.OutputHandler.output_sync(descr, res)
    {:reply, :ok, step}
  end
end
