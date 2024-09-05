defmodule Plaid.IdentityVerification.KycCheck.PhoneNumber do
  @moduledoc """
  [Summary of how phone field matched during KYC check.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-kyc-check-phone-number)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          summary: String.t(),
          area_code: String.t()
        }

  defstruct [:summary, :area_code]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      summary: generic_map["summary"],
      area_code: generic_map["area_code"]
    }
  end
end
