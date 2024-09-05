defmodule Plaid.IdentityVerificationTest do
  use ExUnit.Case, async: true

  alias Plug.Conn

  setup do
    bypass = Bypass.open()
    api_host = "http://localhost:#{bypass.port}/"
    {:ok, bypass: bypass, api_host: api_host}
  end

  test "/identity_verification/create", %{bypass: bypass, api_host: api_host} do
    Bypass.expect_once(bypass, "POST", "/identity_verification/create", fn conn ->
      Conn.resp(conn, 200, identity_verification_raw_response())
    end)

    assert {:ok, parsed_identity_verification()} ==
             Plaid.IdentityVerification.create(
               %{
                 client_user_id: "user-id-202409051444",
                 is_shareable: true,
                 template_id: "idvtmp_4iwgqud9uH1BS7",
                 gave_consent: true,
                 user: %{
                   email_address: "acharleston@email.com",
                   phone_number: "+14155550010",
                   date_of_birth: "1975-01-18",
                   name: %{
                     given_name: "Anna",
                     family_name: "Charleston"
                   },
                   address: %{
                     street: "100 Market Street",
                     street2: "Apt 1A",
                     city: "San Francisco",
                     region: "CA",
                     postal_code: "94103",
                     country: "US"
                   },
                   id_number: %{
                     value: "123456789",
                     type: "us_ssn"
                   }
                 }
               },
               test_api_host: api_host,
               client_id: "123",
               secret: "abc"
             )
  end

  test "/identity_verification/get", %{bypass: bypass, api_host: api_host} do
    Bypass.expect_once(bypass, "POST", "/identity_verification/get", fn conn ->
      Conn.resp(conn, 200, identity_verification_raw_response())
    end)

    assert {:ok, parsed_identity_verification()} ==
             Plaid.IdentityVerification.get("idv_enEDjZD5sX6pUM",
               test_api_host: api_host,
               client_id: "123",
               secret: "abc"
             )
  end

  test "/identity_verification/list", %{bypass: bypass, api_host: api_host} do
    Bypass.expect_once(bypass, "POST", "/identity_verification/list", fn conn ->
      Conn.resp(
        conn,
        200,
        ~s<{
        "identity_verifications": [> <>
          identity_verification_raw_response() <>
          ~s<],
        "next_cursor": null,
        "request_id": "MCUHDbWmCJap0Fb"
      }>
      )
    end)

    assert {:ok,
            %Plaid.IdentityVerification.ListResponse{
              identity_verifications: [parsed_identity_verification()],
              next_cursor: nil,
              request_id: "MCUHDbWmCJap0Fb"
            }} ==
             Plaid.IdentityVerification.list(
               %{template_id: "idvtmp_4iwgqud9uH1BS7", client_user_id: "user-id-202409051444"},
               test_api_host: api_host,
               client_id: "123",
               secret: "abc"
             )
  end

  test "/identity_verification/retry", %{bypass: bypass, api_host: api_host} do
    previous_attempt_id = "flwses_enEDjZD5sX6pUM"

    Bypass.expect_once(bypass, "POST", "/identity_verification/retry", fn conn ->
      Conn.resp(conn, 200, identity_verification_raw_response(previous_attempt_id))
    end)

    assert {:ok,
            Map.put(parsed_identity_verification(), :previous_attempt_id, previous_attempt_id)} ==
             Plaid.IdentityVerification.retry(
               %{
                 client_user_id: "user-id-202409051444",
                 template_id: "idvtmp_4iwgqud9uH1BS7",
                 strategy: "reset",
                 user: %{
                   email_address: "acharleston@email.com",
                   phone_number: "+14155550010",
                   date_of_birth: "1975-01-18",
                   name: %{
                     given_name: "Anna",
                     family_name: "Charleston"
                   },
                   address: %{
                     street: "100 Market Street",
                     street2: "Apt 1A",
                     city: "San Francisco",
                     region: "CA",
                     postal_code: "94103",
                     country: "US"
                   },
                   id_number: %{
                     value: "123456789",
                     type: "us_ssn"
                   }
                 }
               },
               test_api_host: api_host,
               client_id: "123",
               secret: "abc"
             )
  end

  defp identity_verification_raw_response(previous_attempt_id \\ nil) do
    ~s<{
      "client_user_id": "user-id-202409051444",
      "completed_at": null,
      "created_at": "2024-09-05T21:47:05Z",
      "documentary_verification": null,
      "id": "idv_enEDjZD5sX6pUM",
      "kyc_check": null,
      "previous_attempt_id": > <>
      if(is_nil(previous_attempt_id),
        do: "null",
        else: "\"#{previous_attempt_id}\""
      ) <>
      ~s<,
      "redacted_at": null,
      "request_id": "ND2MISjfi2ERTKB",
      "risk_check": null,
      "selfie_check": null,
      "shareable_url": "https://verify-sandbox.plaid.com/verify/idv_enEDjZD5sX6pUM?key=1715da5b74d63e4784aeefaac9ea3124",
      "status": "active",
      "steps": {
        "accept_tos": "skipped",
        "documentary_verification": "not_applicable",
        "kyc_check": "waiting_for_prerequisite",
        "risk_check": "waiting_for_prerequisite",
        "selfie_check": "not_applicable",
        "verify_sms": "active",
        "watchlist_screening": "waiting_for_prerequisite"
      },
      "template": {
        "id": "idvtmp_4iwgqud9uH1BS7",
        "version": 4
      },
      "user": {
        "address": {
          "city": "San Francisco",
          "country": "US",
          "postal_code": "94103",
          "region": "CA",
          "street": "100 Market Street",
          "street2": "Apt 1A"
        },
        "date_of_birth": "1975-01-18",
        "email_address": "acharleston@email.com",
        "id_number": {
          "type": "us_ssn",
          "value": "123456789"
        },
        "ip_address": null,
        "name": {
          "family_name": "Charleston",
          "given_name": "Anna"
        },
        "phone_number": "+14155550010"
      },
      "watchlist_screening_id": null
    }>
  end

  defp parsed_identity_verification do
    %Plaid.IdentityVerification{
      id: "idv_enEDjZD5sX6pUM",
      client_user_id: "user-id-202409051444",
      created_at: "2024-09-05T21:47:05Z",
      completed_at: nil,
      previous_attempt_id: nil,
      shareable_url:
        "https://verify-sandbox.plaid.com/verify/idv_enEDjZD5sX6pUM?key=1715da5b74d63e4784aeefaac9ea3124",
      template: %Plaid.IdentityVerification.Template{
        id: "idvtmp_4iwgqud9uH1BS7",
        version: 4
      },
      user: %Plaid.IdentityVerification.User{
        phone_number: "+14155550010",
        date_of_birth: "1975-01-18",
        ip_address: nil,
        email_address: "acharleston@email.com",
        name: %Plaid.IdentityVerification.User.Name{
          given_name: "Anna",
          family_name: "Charleston"
        },
        address: %Plaid.IdentityVerification.User.Address{
          street: "100 Market Street",
          street2: "Apt 1A",
          city: "San Francisco",
          region: "CA",
          postal_code: "94103",
          country: "US"
        },
        id_number: %Plaid.IdentityVerification.User.IdNumber{
          value: "123456789",
          type: "us_ssn"
        }
      },
      status: "active",
      steps: %Plaid.IdentityVerification.Steps{
        accept_tos: "skipped",
        verify_sms: "active",
        kyc_check: "waiting_for_prerequisite",
        documentary_verification: "not_applicable",
        selfie_check: "not_applicable",
        watchlist_screening: "waiting_for_prerequisite",
        risk_check: "waiting_for_prerequisite"
      },
      documentary_verification: nil,
      selfie_check: nil,
      kyc_check: nil,
      risk_check: nil,
      watchlist_screening_id: nil,
      redacted_at: nil,
      request_id: "ND2MISjfi2ERTKB"
    }
  end
end
