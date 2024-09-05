defmodule Plaid.IdentityVerification.SelfieCheck.Selfie.Analysis do
  @moduledoc """
  [Analysis of the verification of a submitted selfie.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-selfie-check-selfies-analysis)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          document_comparison: String.t()
        }

  defstruct [:document_comparison]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      document_comparison: generic_map["document_comparison"]
    }
  end
end
