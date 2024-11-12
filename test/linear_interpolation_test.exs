defmodule InterpolationCli.LinearInterpolatorTest do
  use ExUnit.Case

  alias InterpolationCli.LinearInterpolator

  test "Correct interpolation between 2 points" do
    points = [{0.0, 0.0}, {1.571, 1.0}]
    step = 1.0

    {description, results} = LinearInterpolator.perform_linear_interpolation(points, step)

    expected_description = """
    Linear (going from point 0.0 with step 1.0, covering all input X (1.57 < 2.0)):
    """

    expected_results = [
      {0.0, 0.0},
      {1.0, 0.6365372374283896},
      {2.0, 1.2730744748567793}
    ]

    assert description == expected_description
    assert results == expected_results
  end
end
