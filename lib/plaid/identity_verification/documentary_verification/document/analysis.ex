defmodule Plaid.IdentityVerification.DocumentaryVerification.Document.Analysis do
  @moduledoc """
  [Analysis of how a document was processed for Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-documentary-verification-documents-analysis)
  """

  alias Plaid.Castable

  @behaviour Castable

  alias Plaid.IdentityVerification.DocumentaryVerification.Document.Analysis.ExtractedData

  @type t :: %__MODULE__{
          authenticity: String.t(),
          image_quality: String.t(),
          extracted_data: ExtractedData.t() | nil
        }

  defstruct [:authenticity, :image_quality, :extracted_data]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      authenticity: generic_map["authenticity"],
      image_quality: generic_map["image_quality"],
      extracted_data: Castable.cast(ExtractedData, generic_map["extracted_data"])
    }
  end
end
