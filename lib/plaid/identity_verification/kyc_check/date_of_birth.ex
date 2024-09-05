defmodule Plaid.IdentityVerification.KycCheck.DateOfBirth do
  @moduledoc """
  [Summary of how date_of_birth field matched during KYC check.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-kyc-check-date-of-birth)
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
