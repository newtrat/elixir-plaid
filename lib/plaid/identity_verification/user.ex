defmodule Plaid.IdentityVerification.User do
  @moduledoc """
  [Plaid user schema for Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-user)
  """

  alias Plaid.Castable
  alias Plaid.IdentityVerification.User.{Address, IdNumber, Name}

  @behaviour Castable

  @type t :: %__MODULE__{
          phone_number: String.t() | nil,
          date_of_birth: String.t() | nil,
          ip_address: String.t() | nil,
          email_address: String.t() | nil,
          name: Name.t() | nil,
          address: Address.t() | nil,
          id_number: IdNumber.t() | nil
        }

  defstruct [
    :phone_number,
    :date_of_birth,
    :ip_address,
    :email_address,
    :name,
    :address,
    :id_number
  ]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      phone_number: generic_map["phone_number"],
      date_of_birth: generic_map["date_of_birth"],
      ip_address: generic_map["ip_address"],
      email_address: generic_map["email_address"],
      name: Castable.cast(Name, generic_map["name"]),
      address: Castable.cast(Address, generic_map["address"]),
      id_number: Castable.cast(IdNumber, generic_map["id_number"])
    }
  end
end
