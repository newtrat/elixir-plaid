defmodule Plaid.IdentityVerification.DocumentaryVerification do
  @moduledoc """
  [Data from the documentary verification step of Plaid Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-documentary-verification)
  """

  alias Plaid.Castable
  alias Plaid.IdentityVerification.DocumentaryVerification.Document

  @behaviour Castable

  @type t :: %__MODULE__{
          status: String.t(),
          documents: [Document.t()]
        }

  defstruct [:status, :documents]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      status: generic_map["status"],
      documents: Castable.cast_list(Document, generic_map["documents"])
    }
  end
end
