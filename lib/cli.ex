defmodule InterpolationCli.CLI do
  @moduledoc """
  CLI module, which handles command line args, inits the application, and listens for data from stdin, forwarding them to InputHandle.
  """

  def main(args) do
    {options, _, _} =
      OptionParser.parse(args,
        switches: [frequency: :integer, step: :float],
        aliases: [f: :frequency, s: :step]
      )

    frequency = Keyword.get(options, :frequency, 10)
    step = Keyword.get(options, :step, 1.0)

    {:ok, _pid} = InterpolationCli.Application.start_link(frequency, step)

    read_input()
  end

  defp read_input do
    # IO.write("> ")

    case IO.gets("") do
      :eof ->
        :ok

      {:error, reason} ->
        IO.puts("Error reading input: #{reason}")

      data ->
        String.trim(data)
        |> String.split(~r/\s+/)
        |> parse_line()

        read_input()
    end
  end

  defp parse_line([x_str, y_str]) do
    case {Float.parse(x_str), Float.parse(y_str)} do
      {{x, ""}, {y, ""}} ->
        InterpolationCli.InputHandler.add_point(x, y)

      _ ->
        IO.puts("Invalid input format. Expected: x y")
    end
  end

  defp parse_line(_), do: IO.puts("Неверный формат ввода. Ожидается: x y")
end
