defmodule ExToolkit.Encode.Base62UUIDTest do
  use ExUnit.Case, async: true

  alias ExToolkit.Encode.Base62UUID

  # This is also important to test ExToolkit.Kernel itself
  doctest Base62UUID
end
