defmodule InterpolationCli.OutputHandler do
  @moduledoc """
  Module for processing output. 
  Takes interpolation results and outputs it to starndard output in a specific format.
  """

  use GenServer

  # API
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def output(descr, results) do
    GenServer.cast(__MODULE__, {:output, descr, results})
  end

  def output_sync(descr, results) do
    GenServer.call(__MODULE__, {:output_sync, descr, results})
  end

  # Callbacks
  @impl true
  def init(_) do
    {:ok, []}
  end

  @impl true
  def handle_cast({:output, descr, res}, state) do
    print_output(descr, res)
    {:noreply, state}
  end

  @impl true
  def handle_call({:output_sync, descr, res}, _from, state) do
    print_output(descr, res)
    {:reply, :ok, state}
  end

  def print_output(descr, res) do
    IO.puts("")
    IO.write(descr)

    xs = Enum.map_join(res, "\t", fn {x, _} -> Float.round(to_float(x), 2) end)
    ys = Enum.map_join(res, "\t", fn {_, y} -> Float.round(to_float(y), 2) end)

    IO.puts(xs)
    IO.puts(ys)
    IO.puts("")
  end

  defp to_float(value) when is_integer(value), do: value * 1.0
  defp to_float(value), do: value
end
