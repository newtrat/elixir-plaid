defmodule Plaid.IdentityVerification.User.IdNumber do
  @moduledoc """
  [User's government ID for Plaid Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-user-id-number)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
    value: String.t(),
    type: String.t()
  }

  defstruct [:value, :type]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      value: generic_map["value"],
      type: generic_map["type"]
    }
  end
end
