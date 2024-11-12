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
    Enum.each(results, fn {x, y} ->
      IO.puts("#{Float.round(x, 3)}\t#{Float.round(y, 3)}")
    end)

    {:noreply, state}
  end
end
