defmodule InterpolationCli.CLI do
  @moduledoc """
  CLI module, which handles command line args, inits the application, and listens for data from stdin, forwarding them to InputHandle.
  """

  def main(args) do
    Process.flag(:trap_exit, true)

    {options, _, _} =
      OptionParser.parse(args,
        switches: [algorithm: :string, frequency: :integer, step: :float],
        aliases: [a: :algorithm, f: :frequency, s: :step]
      )

    frequency = Keyword.get(options, :frequency, 10)
    step = Keyword.get(options, :step, 1.0)

    algorithms =
      case options[:algorithm] do
        nil ->
          [:linear]

        algos ->
          algos
          |> String.split(",")
          |> Enum.map(&String.trim/1)
          |> Enum.map(&String.to_atom/1)
      end

    algorithms = if algorithms == [], do: [:linear], else: algorithms

    {:ok, supervisor_pid} = InterpolationCli.Application.start_link(algorithms, frequency, step)

    read_input()

    await_shutdown(supervisor_pid)
  end

  defp read_input do
    IO.stream(:stdio, :line)
    |> Enum.each(fn line ->
      String.trim(line)
      |> String.split(~r/\s+/)
      |> parse_line()
    end)

    InterpolationCli.InputHandler.input_finished()
  end

  defp parse_line([x_str, y_str]) do
    case {Float.parse(x_str), Float.parse(y_str)} do
      {{x, ""}, {y, ""}} ->
        InterpolationCli.InputHandler.add_point(x, y)

      _ ->
        IO.puts("Invalid input format. Expected: x y")
    end
  end

  defp parse_line(_), do: IO.puts("Invalid input format. Expected: x y")

  defp await_shutdown(supervisor_pid) do
    receive do
      {:EXIT, ^supervisor_pid, _reason} ->
        IO.puts("All tasks completed, shutting down.")
    after
      10 ->
        IO.puts("Timeout waiting for processes to complete.")
    end
  end
end
