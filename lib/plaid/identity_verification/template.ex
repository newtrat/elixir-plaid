defmodule Plaid.IdentityVerification.Template do
  @moduledoc """
  [Plaid Identity Verification template.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-template)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          id: String.t(),
          version: integer()
        }

  defstruct [:id, :version]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      id: generic_map["id"],
      version: generic_map["version"]
    }
  end
end
