defmodule Plaid.IdentityVerification.KycCheck.IdNumber do
  @moduledoc """
  [Summary of how id_number field matched during KYC check.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-kyc-check-id-number)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          summary: String.t()
        }

  defstruct [:summary]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      summary: generic_map["summary"]
    }
  end
end
