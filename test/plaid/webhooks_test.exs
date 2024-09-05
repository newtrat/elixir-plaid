defmodule Plaid.WebhooksTest do
  use ExUnit.Case, async: true

  alias Plug.Conn

  @kid "c44a8d01-440a-425d-9801-97da26b53a7b"

  # This JWK was generated with JOSE.JWS.generate_key/1
  @json_web_key %{
    "alg" => "ES256",
    "crv" => "P-256",
    "d" => "csr36_se-89-CKdY4nGnbRXNWVntBY03bmMQXSQ3yOg",
    "kty" => "EC",
    "use" => "sig",
    "x" => "bGe_0GV8Kf1kiD9dP9d02h3KmgKe3YndLIyljFpY-Hw",
    "y" => "a-x6gUbGHWX4rK9233n-4FU6rzkwBhUV_AJSdOuOMIs"
  }

  def create_jwt(raw_body) do
    iat = DateTime.to_unix(DateTime.utc_now())

    request_body_sha256 =
      :sha256
      |> :crypto.hash(raw_body)
      |> Base.encode16(padding: false, case: :lower)

    signer = Joken.Signer.create("ES256", @json_web_key, %{"kid" => @kid})

    {:ok, jwt} =
      %{}
      |> Map.put("iat", iat)
      |> Map.put("request_body_sha256", request_body_sha256)
      |> Joken.Signer.sign(signer)

    jwt
  end

  setup do
    bypass = Bypass.open()
    api_host = "http://localhost:#{bypass.port}/"

    # Default case for tests, all should recieve this key.
    Bypass.stub(bypass, "POST", "/webhook_verification_key/get", fn conn ->
      now = DateTime.to_unix(DateTime.utc_now())

      Conn.resp(conn, 200, ~s<{
        "key": {
          "alg": "ES256",
          "created_at": #{now},
          "crv": "P-256",
          "expired_at": null,
          "kid": "#{@kid}",
          "kty": "EC",
          "use": "sig",
          "x": "bGe_0GV8Kf1kiD9dP9d02h3KmgKe3YndLIyljFpY-Hw",
          "y": "a-x6gUbGHWX4rK9233n-4FU6rzkwBhUV_AJSdOuOMIs"
        },
        "request_id": "RZ6Omi1bzzwDaLo"
      }>)
    end)

    {:ok, bypass: bypass, api_host: api_host}
  end

  describe "verify_and_construct/2" do
    test "errors when JWT header algorithm is not ES256" do
      signer = Joken.Signer.create("HS256", "secret")
      {:ok, jwt, _} = Joken.encode_and_sign(%{}, signer)

      {:error, :invalid_algorithm} =
        Plaid.Webhooks.verify_and_construct(jwt, "{}", client_id: "abc", secret: "123")
    end

    test "errors when plaid public key request fails", %{bypass: bypass, api_host: api_host} do
      Bypass.expect_once(bypass, "POST", "/webhook_verification_key/get", fn conn ->
        Conn.resp(
          conn,
          400,
          ~s<{
            "display_message": null,
            "documentation_url": "https://plaid.com/docs/?ref=error#invalid-request-errors",
            "error_code": "MISSING_FIELDS",
            "error_message": "the following required fields are missing: client_id, secret",
            "error_type": "INVALID_REQUEST",
            "request_id": "TN8syo3X9zbu1z1",
            "suggested_action": null
          }>
        )
      end)

      raw_body =
        ~s<{"webhook_type": "PAYMENT_INITIATION", "webhook_code": "PAYMENT_STATUS_UPDATE", "payment_id": "payment-id-production-2ba30780-d549-4335-b1fe-c2a938aa39d2", "new_payment_status": "PAYMENT_STATUS_INITIATED", "old_payment_status": "PAYMENT_STATUS_PROCESSING", "original_reference": "Account Funding 99744", "adjusted_reference": "Account Funding 99", "original_start_date": "2017-09-14", "adjusted_start_date": "2017-09-15", "timestamp": "2017-09-14T14:42:19.350Z", "error": null}>

      jwt = create_jwt(raw_body)

      {:error, %Plaid.Error{}} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "errors when request body doesn't match token sha256", %{api_host: api_host} do
      token_body =
        ~s<{"webhook_type": "PAYMENT_INITIATION", "webhook_code": "PAYMENT_STATUS_UPDATE", "payment_id": "payment-id-production-2ba30780-d549-4335-b1fe-c2a938aa39d2", "new_payment_status": "PAYMENT_STATUS_INITIATED", "old_payment_status": "PAYMENT_STATUS_PROCESSING", "original_reference": "Account Funding 99744", "adjusted_reference": "Account Funding 99", "original_start_date": "2017-09-14", "adjusted_start_date": "2017-09-15", "timestamp": "2017-09-14T14:42:19.350Z", "error": null}>

      jwt = create_jwt(token_body)

      {:error, :invalid_body} =
        Plaid.Webhooks.verify_and_construct(jwt, "{}",
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "Item error webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "ITEM", "webhook_code": "ERROR", "item_id": "wz666MBjYWTp2PDzzggYhM6oWWmBb", "error": {"display_message": null, "error_code": "ITEM_LOGIN_REQUIRED", "error_message": "the login details of this item have changed", "error_type": "ITEM_ERROR", "status": 400}}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.ItemError{
         webhook_type: "ITEM",
         webhook_code: "ERROR",
         item_id: "wz666MBjYWTp2PDzzggYhM6oWWmBb",
         error: %Plaid.Error{
           display_message: nil,
           error_code: "ITEM_LOGIN_REQUIRED",
           error_message: "the login details of this item have changed",
           error_type: "ITEM_ERROR",
           status: 400
         }
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "Item pending expiration webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "ITEM", "webhook_code": "PENDING_EXPIRATION", "item_id": "wz666MBjYWTp2PDzzggYhM6oWWmBb", "consent_expiration_time": "2020-01-15T13:25:17.766Z"}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.ItemPendingExpiration{
         webhook_type: "ITEM",
         webhook_code: "PENDING_EXPIRATION",
         item_id: "wz666MBjYWTp2PDzzggYhM6oWWmBb",
         consent_expiration_time: "2020-01-15T13:25:17.766Z"
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "Item user permission revoked webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "ITEM", "webhook_code": "USER_PERMISSION_REVOKED", "error": {"error_code": "USER_PERMISSION_REVOKED", "error_message": "the holder of this account has revoked their permission", "error_type": "ITEM_ERROR", "status": 400}, "item_id": "gAXlMgVEw5uEGoQnnXZ6tn9E7Mn3LBc4PJVKZ"}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.ItemUserPermissionRevoked{
         webhook_type: "ITEM",
         webhook_code: "USER_PERMISSION_REVOKED",
         error: %Plaid.Error{
           error_code: "USER_PERMISSION_REVOKED",
           error_message: "the holder of this account has revoked their permission",
           error_type: "ITEM_ERROR",
           status: 400
         },
         item_id: "gAXlMgVEw5uEGoQnnXZ6tn9E7Mn3LBc4PJVKZ"
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "Item webhook update acknowledged webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "ITEM", "webhook_code": "WEBHOOK_UPDATE_ACKNOWLEDGED", "item_id": "wz666MBjYWTp2PDzzggYhM6oWWmBb", "error": null, "new_webhook_url": "https://plaid.com/example/webhook"}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.ItemWebhookUpdateAcknowledged{
         webhook_type: "ITEM",
         webhook_code: "WEBHOOK_UPDATE_ACKNOWLEDGED",
         item_id: "wz666MBjYWTp2PDzzggYhM6oWWmBb",
         error: nil,
         new_webhook_url: "https://plaid.com/example/webhook"
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "transactions initial update webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "TRANSACTIONS", "webhook_code": "INITIAL_UPDATE", "item_id": "wz666MBjYWTp2PDzzggYhM6oWWmBb", "error": null, "new_transactions": 19}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.TransactionsUpdate{
         webhook_type: "TRANSACTIONS",
         webhook_code: "INITIAL_UPDATE",
         item_id: "wz666MBjYWTp2PDzzggYhM6oWWmBb",
         error: nil,
         new_transactions: 19
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "transactions historical update webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "TRANSACTIONS", "webhook_code": "HISTORICAL_UPDATE", "item_id": "wz666MBjYWTp2PDzzggYhM6oWWmBb", "error": null, "new_transactions": 231}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.TransactionsUpdate{
         webhook_type: "TRANSACTIONS",
         webhook_code: "HISTORICAL_UPDATE",
         item_id: "wz666MBjYWTp2PDzzggYhM6oWWmBb",
         error: nil,
         new_transactions: 231
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "transactions default update webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "TRANSACTIONS", "webhook_code": "DEFAULT_UPDATE", "item_id": "wz666MBjYWTp2PDzzggYhM6oWWmBb", "error": null, "new_transactions": 3}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.TransactionsUpdate{
         webhook_type: "TRANSACTIONS",
         webhook_code: "DEFAULT_UPDATE",
         item_id: "wz666MBjYWTp2PDzzggYhM6oWWmBb",
         error: nil,
         new_transactions: 3
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "transactions removed webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "TRANSACTIONS", "webhook_code": "TRANSACTIONS_REMOVED", "item_id": "wz666MBjYWTp2PDzzggYhM6oWWmBb", "removed_transactions": ["yBVBEwrPyJs8GvR77N7QTxnGg6wG74H7dEDN6", "kgygNvAVPzSX9KkddNdWHaVGRVex1MHm3k9no"], "error": null}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.TransactionsRemoved{
         webhook_type: "TRANSACTIONS",
         webhook_code: "TRANSACTIONS_REMOVED",
         item_id: "wz666MBjYWTp2PDzzggYhM6oWWmBb",
         removed_transactions: [
           "yBVBEwrPyJs8GvR77N7QTxnGg6wG74H7dEDN6",
           "kgygNvAVPzSX9KkddNdWHaVGRVex1MHm3k9no"
         ],
         error: nil
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "auth automatically verified webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "AUTH", "webhook_code": "AUTOMATICALLY_VERIFIED", "item_id": "eVBnVMp7zdTJLkRNr33Rs6zr7KNJqBFL9DrE6", "account_id": "dVzbVMLjrxTnLjX4G66XUp5GLklm4oiZy88yK"}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.Auth{
         webhook_type: "AUTH",
         webhook_code: "AUTOMATICALLY_VERIFIED",
         item_id: "eVBnVMp7zdTJLkRNr33Rs6zr7KNJqBFL9DrE6",
         account_id: "dVzbVMLjrxTnLjX4G66XUp5GLklm4oiZy88yK"
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "auth verification expired webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "AUTH", "webhook_code": "VERIFICATION_EXPIRED", "item_id": "eVBnVMp7zdTJLkRNr33Rs6zr7KNJqBFL9DrE6", "account_id": "BxBXxLj1m4HMXBm9WZZmCWVbPjX16EHwv99vp"}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.Auth{
         webhook_type: "AUTH",
         webhook_code: "VERIFICATION_EXPIRED",
         item_id: "eVBnVMp7zdTJLkRNr33Rs6zr7KNJqBFL9DrE6",
         account_id: "BxBXxLj1m4HMXBm9WZZmCWVbPjX16EHwv99vp"
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "assets product ready webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "ASSETS", "webhook_code": "PRODUCT_READY", "asset_report_id": "47dfc92b-bba3-4583-809e-ce871b321f05"}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.AssetsProductReady{
         webhook_type: "ASSETS",
         webhook_code: "PRODUCT_READY",
         asset_report_id: "47dfc92b-bba3-4583-809e-ce871b321f05"
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "assets error webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "ASSETS", "webhook_code": "ERROR", "asset_report_id": "47dfc92b-bba3-4583-809e-ce871b321f05", "error": {"display_message": null, "error_code": "PRODUCT_NOT_ENABLED", "error_message": "the 'assets' product is not enabled", "error_type": "ASSET_REPORT_ERROR", "request_id": "m8MDnv9okwxFNBV"}}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.AssetsError{
         webhook_type: "ASSETS",
         webhook_code: "ERROR",
         asset_report_id: "47dfc92b-bba3-4583-809e-ce871b321f05",
         error: %Plaid.Error{
           display_message: nil,
           error_code: "PRODUCT_NOT_ENABLED",
           error_message: "the 'assets' product is not enabled",
           error_type: "ASSET_REPORT_ERROR",
           request_id: "m8MDnv9okwxFNBV"
         }
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "holdings default update webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "HOLDINGS", "webhook_code": "DEFAULT_UPDATE", "item_id": "wz666MBjYWTp2PDzzggYhM6oWWmBb", "error": null, "new_holdings": 19, "updated_holdings": 0}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.HoldingsUpdate{
         webhook_type: "HOLDINGS",
         webhook_code: "DEFAULT_UPDATE",
         item_id: "wz666MBjYWTp2PDzzggYhM6oWWmBb",
         error: nil,
         new_holdings: 19,
         updated_holdings: 0
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "identity verification webhooks", %{api_host: api_host} do
      for code <- ["STATUS_UPDATED", "STEP_UPDATED", "RETRIED"] do
        raw_body =
          ~s<{
               "webhook_type": "IDENTITY_VERIFICATION",
               "webhook_code": "> <>
            code <>
            ~s<",
               "identity_verification_id": "idv_52xR9LKo77r1Np",
               "environment": "production"
             }>

        jwt = create_jwt(raw_body)

        assert {:ok,
                %Plaid.Webhooks.IdentityVerification{
                  webhook_type: "IDENTITY_VERIFICATION",
                  webhook_code: ^code,
                  identity_verification_id: "idv_52xR9LKo77r1Np",
                  environment: "production"
                }} =
                 Plaid.Webhooks.verify_and_construct(jwt, raw_body,
                   client_id: "abc",
                   secret: "123",
                   test_api_host: api_host
                 )
      end
    end

    test "investments transactions default update webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "INVESTMENTS_TRANSACTIONS", "webhook_code": "DEFAULT_UPDATE", "item_id": "wz666MBjYWTp2PDzzggYhM6oWWmBb", "error": null, "new_investments_transactions": 16, "canceled_investments_transactions": 0}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.InvestmentsTransactionsUpdate{
         webhook_type: "INVESTMENTS_TRANSACTIONS",
         webhook_code: "DEFAULT_UPDATE",
         item_id: "wz666MBjYWTp2PDzzggYhM6oWWmBb",
         error: nil,
         new_investments_transactions: 16,
         canceled_investments_transactions: 0
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    test "payment inititation payment status update webhook", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "PAYMENT_INITIATION", "webhook_code": "PAYMENT_STATUS_UPDATE", "payment_id": "payment-id-production-2ba30780-d549-4335-b1fe-c2a938aa39d2", "new_payment_status": "PAYMENT_STATUS_INITIATED", "old_payment_status": "PAYMENT_STATUS_PROCESSING", "original_reference": "Account Funding 99744", "adjusted_reference": "Account Funding 99", "original_start_date": "2017-09-14", "adjusted_start_date": "2017-09-15", "timestamp": "2017-09-14T14:42:19.350Z", "error": null}>

      jwt = create_jwt(raw_body)

      {:ok,
       %Plaid.Webhooks.PaymentInitiationPaymentStatusUpdate{
         webhook_type: "PAYMENT_INITIATION",
         webhook_code: "PAYMENT_STATUS_UPDATE",
         payment_id: "payment-id-production-2ba30780-d549-4335-b1fe-c2a938aa39d2",
         new_payment_status: "PAYMENT_STATUS_INITIATED",
         old_payment_status: "PAYMENT_STATUS_PROCESSING",
         original_reference: "Account Funding 99744",
         adjusted_reference: "Account Funding 99",
         original_start_date: "2017-09-14",
         adjusted_start_date: "2017-09-15",
         timestamp: "2017-09-14T14:42:19.350Z",
         error: nil
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end

    @tag capture_log: true
    test "unrecognized webhook still returns raw response", %{api_host: api_host} do
      raw_body =
        ~s<{"webhook_type": "IDK", "webhook_code": "NEVER_HEARD_OF_IT", "payment_id": "payment-id-production-2ba30780-d549-4335-b1fe-c2a938aa39d2"}>

      jwt = create_jwt(raw_body)

      {:ok,
       %{
         "webhook_type" => "IDK",
         "webhook_code" => "NEVER_HEARD_OF_IT",
         "payment_id" => "payment-id-production-2ba30780-d549-4335-b1fe-c2a938aa39d2"
       }} =
        Plaid.Webhooks.verify_and_construct(jwt, raw_body,
          client_id: "abc",
          secret: "123",
          test_api_host: api_host
        )
    end
  end
end
