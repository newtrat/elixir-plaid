defmodule Plaid.IdentityVerification.User.Name do
  @moduledoc """
  [User's name for Plaid Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-user-name)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
    given_name: String.t(),
    family_name: String.t()
  }

  defstruct [:given_name, :family_name]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      given_name: generic_map["given_name"],
      family_name: generic_map["family_name"]
    }
  end
end
