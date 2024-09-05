defmodule Plaid.IdentityVerification.DocumentaryVerification.Document.Analysis.ExtractedData do
  @moduledoc """
  [Abbreviated list of data extracted by OCR from a submitted document, used for analysis.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-documentary-verification-documents-analysis-extracted-data)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          name: String.t(),
          date_of_birth: String.t(),
          expiration_date: String.t(),
          issuing_country: String.t()
        }

  defstruct [:name, :date_of_birth, :expiration_date, :issuing_country]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      name: generic_map["name"],
      date_of_birth: generic_map["date_of_birth"],
      expiration_date: generic_map["expiration_date"],
      issuing_country: generic_map["issuing_country"]
    }
  end
end
