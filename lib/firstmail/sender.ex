defmodule Firstmail.Sender do
  alias Firstmail.Utils

  def send(config, %{from: from} = email) do
    enabled = Keyword.get(config, :enabled, false)
    pubkey = Keyword.fetch!(config, :pubkey)
    domain = Utils.domain(from)

    # DNS.resolve "firstmail.one", :txt
    # DNS.resolve "_dmarc.firstmail.one", :txt
    # DNS.resolve "dkim._domainkey.firstmail.one", :txt
    if enabled do
      with {:ok, [['v=spf1 include:firstmail.dev -all']]} <- DNS.resolve(domain, :txt),
           dmarc <- 'v=DMARC1; p=reject; rua=mailto:#{from}',
           {:ok, [[^dmarc]]} <-
             DNS.resolve("_dmarc.#{domain}", :txt),
           {:ok, [list]} <- DNS.resolve("dkim._domainkey.#{domain}", :txt),
           true <- is_list(list),
           dkim <- "v=DKIM1; p=#{pubkey};",
           ^dkim <- Enum.join(list) do
        String.split(email.to, ", ", trim: true)
        |> Enum.map(fn to -> send_one(config, email, to) end)
        |> multi_result()
      else
        res -> {:error, res}
      end
    else
      {:ok, :disabled}
    end
  end

  def multi_result(res_list) do
    count =
      res_list
      |> Enum.map(fn
        {:ok, _} -> 1
        _ -> 0
      end)
      |> Enum.sum()

    case Enum.count(res_list) do
      ^count -> {:ok, res_list}
      _ -> {:error, res_list}
    end
  end

  def send_one(config, email, to) do
    email = Map.put(email, :to, to)
    send_sync_mxdns(config, email)
  end

  def send_sync_mxdns(config, email) do
    hostname = Keyword.fetch!(config, :hostname)
    privkey = Keyword.fetch!(config, :privkey)

    %{
      subject: subject,
      reply: reply,
      mime: mime,
      body: body,
      from: from,
      to: to
    } = email

    reply =
      case is_binary(reply) do
        true -> reply
        _ -> from
      end

    dkim_opts = [
      {:s, "dkim"},
      {:d, Utils.domain(from)},
      {:private_key, {:pem_plain, privkey}}
    ]

    [mime_1, mime_2] = String.split(mime, "/")

    # default encoding utf-8 if iconv is present
    signed_mail_body =
      :mimemail.encode(
        {mime_1, mime_2,
         [
           {"List-Unsubscribe", "<mailto:#{reply}?subject=Unsubscribe>"},
           {"Subject", subject},
           {"Reply-To", reply},
           {"From", from},
           {"To", to}
         ], %{content_type_params: [{"charset", "utf-8"}]}, body},
        dkim: dkim_opts
      )

    domain = Utils.domain(to)

    send_opts = [
      tls: :always,
      relay: domain,
      hostname: hostname,
      tls_options: [
        verify: :verify_peer,
        depth: 99,
        cacerts: :certifi.cacerts(),
        customize_hostname_check: [
          match_fun: fn _, _ -> true end
        ]
      ]
    ]

    result =
      :gen_smtp_client.send_blocking(
        {
          from,
          [to],
          signed_mail_body
        },
        send_opts
      )

    # {:error, :retries_exceeded, {:network_failure, 'alt4.gmr-smtp-in.l.google.com', {:error, :econnrefused}}}
    case result do
      mail_id when is_binary(mail_id) -> {:ok, mail_id}
      error -> error
    end
  end
end
