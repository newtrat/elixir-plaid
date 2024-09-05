defmodule Plaid.IdentityVerification.DocumentaryVerification.Document do
  @moduledoc """
  [A single user submission to the documentary verification step of Plaid Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-documentary-verification-documents)
  """

  alias Plaid.Castable

  alias Plaid.IdentityVerification.DocumentaryVerification.Document.{
    Analysis,
    ExtractedData,
    Image
  }

  @behaviour Castable

  @type t :: %__MODULE__{
          status: String.t(),
          attempt: integer(),
          images: [Image.t()],
          extracted_data: ExtractedData.t(),
          analysis: Analysis.t(),
          redacted_at: String.t() | nil
        }

  defstruct [:status, :attempt, :images, :extracted_data, :analysis, :redacted_at]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      status: generic_map["status"],
      attempt: generic_map["attempt"],
      images: Castable.cast_list(Image, generic_map["images"]),
      extracted_data: Castable.cast(ExtractedData, generic_map["extracted_data"]),
      analysis: Castable.cast(Analysis, generic_map["analysis"]),
      redacted_at: generic_map["redacted_at"]
    }
  end
end
