defmodule Plaid.IdentityVerification.DocumentaryVerification.Document.ExtractedData do
  @moduledoc """
  [Data extracted by OCR from a document submitted for Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-documentary-verification-documents-extracted-data)
  """

  alias Plaid.Castable
  alias Plaid.IdentityVerification.DocumentaryVerification.Document.ExtractedData.Address
  alias Plaid.IdentityVerification.User.Name

  @behaviour Castable

  @type t :: %__MODULE__{
          id_number: String.t() | nil,
          category: String.t(),
          expiration_date: String.t() | nil,
          issuing_country: String.t(),
          issuing_region: String.t() | nil,
          date_of_birth: String.t() | nil,
          address: Address.t() | nil,
          name: Name.t() | nil
        }

  defstruct [
    :id_number,
    :category,
    :expiration_date,
    :issuing_country,
    :issuing_region,
    :date_of_birth,
    :address,
    :name
  ]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      id_number: generic_map["id_number"],
      category: generic_map["category"],
      expiration_date: generic_map["expiration_date"],
      issuing_country: generic_map["issuing_country"],
      issuing_region: generic_map["issuing_region"],
      date_of_birth: generic_map["date_of_birth"],
      address: Castable.cast(Address, generic_map["address"]),
      name: Castable.cast(Name, generic_map["name"])
    }
  end
end
