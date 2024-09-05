defmodule Plaid.IdentityVerification.KycCheck do
  @moduledoc """
  [Additional information for the kyc_check step of Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-kyc-check)
  """

  alias Plaid.Castable
  alias Plaid.IdentityVerification.KycCheck.{Address, DateOfBirth, IdNumber, Name, PhoneNumber}

  @behaviour Castable

  @type t :: %{
          status: String.t(),
          address: Address.t(),
          name: Name.t(),
          date_of_birth: DateOfBirth.t(),
          id_number: IdNumber.t(),
          phone_number: PhoneNumber.t()
        }

  defstruct [:status, :address, :name, :date_of_birth, :id_number, :phone_number]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      status: generic_map["status"],
      address: Castable.cast(Address, generic_map["address"]),
      name: Castable.cast(Name, generic_map["name"]),
      date_of_birth: Castable.cast(DateOfBirth, generic_map["date_of_birth"]),
      id_number: Castable.cast(IdNumber, generic_map["id_number"]),
      phone_number: Castable.cast(PhoneNumber, generic_map["phone_number"])
    }
  end
end
