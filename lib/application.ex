defmodule InterpolationCli.Application do
  @moduledoc """
  Main application module - inits supervisor and processes for handling i/o and interpolation
  """

  use Application

  def start(_type, _args) do
    {:ok, self()}
  end

  def start_link(algo, frequency, step) do
    do_nothing_with_frequency(frequency)

    # Set algorithms in application environment for access in InputHandler
    Application.put_env(:interpolation_cli, :algorithms, algo)

    base_children = [
      {InterpolationCli.InputHandler, []},
      {InterpolationCli.OutputHandler, []}
    ]

    additional_children = []

    additional_children =
      if :linear in algo,
        do: additional_children ++ [{InterpolationCli.LinearInterpolator, step}],
        else: additional_children

    additional_children =
      if :lagrange in algo,
        do: additional_children ++ [{InterpolationCli.LagrangeInterpolator, step}],
        else: additional_children

    # Combine all children
    children = Enum.concat(base_children, additional_children)

    opts = [strategy: :one_for_one, name: InterpolationCli.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Dummy function that does nothing but uses frequency
  defp do_nothing_with_frequency(_frequency) do
    :ok
  end
end
