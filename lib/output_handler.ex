defmodule InterpolationCli.OutputHandler do
  @moduledoc """
  Модуль для обработки вывода. Принимает результаты интерполяции и выводит их
  на стандартный вывод в заданном формате.
  """

  use GenServer

  # API
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def output(results) do
    GenServer.cast(__MODULE__, {:output, results})
  end

  # Callbacks
  @impl true
  def init(_) do
    {:ok, []}
  end

  @impl true
  def handle_cast({:output, results}, state) do
    xs = Enum.map_join(results, "\t", fn {x, _} -> Float.round(x, 2) end)
    ys = Enum.map_join(results, "\t", fn {_, y} -> Float.round(y, 2) end)

    # Вывод X и Y координат
    IO.puts(xs)
    IO.puts(ys)
    IO.puts("")

    {:noreply, state}
  end
end
