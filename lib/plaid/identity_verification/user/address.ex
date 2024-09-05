defmodule Plaid.IdentityVerification.User.Address do
  @moduledoc """
  [User address schema for Plaid Identity Verification](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-user-address)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
    street: String.t(),
    street2: String.t() | nil,
    city: String.t() | nil,
    region: String.t() | nil,
    postal_code: String.t() | nil,
    country: String.t()
  }

  defstruct [:street, :street2, :city, :region, :postal_code, :country]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      street: generic_map["street"],
      street2: generic_map["street2"],
      city: generic_map["city"],
      region: generic_map["region"],
      postal_code: generic_map["postal_code"],
      country: generic_map["country"]
    }
  end
end
