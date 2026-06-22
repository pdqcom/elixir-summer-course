defmodule School.Player do
  @type t :: %__MODULE__{
          name: String.t(),
          score: integer(),
          pid: pid()
        }

  defstruct name: "Bob",
            score: 0,
            pid: nil
end
