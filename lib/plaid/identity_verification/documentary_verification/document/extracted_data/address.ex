defmodule Plaid.IdentityVerification.DocumentaryVerification.Document.ExtractedData.Address do
  @moduledoc """
  [An address extracted from a submitted document during Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-documentary-verification-documents-extracted-data-address)
  The same as `Plaid.Address` except that `street`, `city`, and `country` are required.
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          street: String.t(),
          city: String.t(),
          region: String.t() | nil,
          postal_code: String.t() | nil,
          country: String.t()
        }

  defstruct [:street, :city, :region, :postal_code, :country]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      street: generic_map["street"],
      city: generic_map["city"],
      region: generic_map["region"],
      postal_code: generic_map["postal_code"],
      country: generic_map["country"]
    }
  end
end
