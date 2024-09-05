defmodule Plaid.IdentityVerification.SelfieCheck.Selfie do
  @moduledoc """
  [A selfie submitted to selfie_check for Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-selfie-check-selfies)
  """

  alias Plaid.Castable
  alias Plaid.IdentityVerification.SelfieCheck.Selfie.{Capture, Analysis}

  @behaviour Castable

  @type t :: %__MODULE__{
          status: String.t(),
          attempt: integer(),
          capture: Capture.t(),
          analysis: Analysis.t()
        }

  defstruct [:status, :attempt, :capture, :analysis]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      status: generic_map["status"],
      attempt: generic_map["attempt"],
      capture: Castable.cast(Capture, generic_map["capture"]),
      analysis: Castable.cast(Analysis, generic_map["analysis"])
    }
  end
end
