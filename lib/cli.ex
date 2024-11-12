defmodule InterpolationCli.CLI do
  @moduledoc """
  Модуль CLI, который обрабатывает аргументы командной строки, инициализирует приложение
  и принимает данные с ввода, передавая их в InputHandler для дальнейшей обработки.
  """

  def main(args) do
    # Парсим аргументы командной строки
    {options, _, _} =
      OptionParser.parse(args,
        switches: [frequency: :integer, step: :float],
        aliases: [f: :frequency, s: :step]
      )

    # По умолчанию 10
    frequency = Keyword.get(options, :frequency, 10)
    step = Keyword.get(options, :step, 1.0)

    # Запуск основного приложения
    {:ok, _pid} = InterpolationCli.Application.start_link(frequency, step)

    # Читаем входные данные
    read_input()
  end

  defp read_input do
    # IO.write("> ")

    case IO.gets("") do
      :eof ->
        :ok

      {:error, reason} ->
        IO.puts("Ошибка чтения ввода: #{reason}")

      data ->
        String.trim(data)
        |> String.split()
        |> parse_line()

        read_input()
    end
  end

  defp parse_line([x_str, y_str]) do
    case {Float.parse(x_str), Float.parse(y_str)} do
      {{x, ""}, {y, ""}} ->
        # Отправляем данные обработчику входа
        InterpolationCli.InputHandler.add_point(x, y)

      _ ->
        IO.puts("Неверный формат ввода. Ожидается: x y")
    end
  end

  defp parse_line(_), do: IO.puts("Неверный формат ввода. Ожидается: x y")
end
