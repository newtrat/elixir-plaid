defmodule Plaid.IdentityVerification.SelfieCheck do
  @moduledoc """
  [Additional information for the selfie_check step of Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-selfie-check)
  """

  alias Plaid.Castable
  alias Plaid.IdentityVerification.SelfieCheck.Selfie

  @behaviour Castable

  @type t :: %__MODULE__{
          status: String.t(),
          selfies: [Selfie.t()]
        }

  defstruct [:status, :selfies]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      status: generic_map["status"],
      selfies: Castable.cast_list(Selfie, generic_map["selfies"])
    }
  end
end
