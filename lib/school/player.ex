defmodule School.Player do
  @type t :: %__MODULE__{
          name: String.t(),
          score: integer()
        }

  defstruct name: "Bob",
            score: 0
end
