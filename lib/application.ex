defmodule InterpolationCli.Application do
  @moduledoc """
  Главный модуль приложения, запускающий супервизор и инициализирующий процессы
  для обработки ввода, интерполяции и вывода данных.
  """

  use Application

  def start(_type, _args) do
    # Это нужно для соответствия спецификации Application
    {:ok, self()}
  end

  def start_link(frequency, step) do
    # Запускаем супервизор
    children = [
      {InterpolationCli.InputHandler, []},
      {InterpolationCli.LinearInterpolator, frequency, step},
      {InterpolationCli.OutputHandler, []}
    ]

    opts = [strategy: :one_for_one, name: InterpolationCli.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
