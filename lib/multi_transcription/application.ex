defmodule MultiTranscription.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    {:ok, model_info} = Bumblebee.load_model({:hf, "distil-whisper/distil-large-v3"})
    {:ok, featurizer} = Bumblebee.load_featurizer({:hf, "distil-whisper/distil-large-v3"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "distil-whisper/distil-large-v3"})

    {:ok, generation_config} =
      Bumblebee.load_generation_config({:hf, "distil-whisper/distil-large-v3"})

    serving =
      Bumblebee.Audio.speech_to_text_whisper(model_info, featurizer, tokenizer, generation_config,
        defn_options: [compiler: EXLA]
      )

    children = [
      {Nx.Serving, name: WhisperServing, serving: serving},
      MultiTranscriptionWeb.Telemetry,
      MultiTranscription.Repo,
      {DNSCluster,
       query: Application.get_env(:multi_transcription, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MultiTranscription.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MultiTranscription.Finch},
      # Start a worker by calling: MultiTranscription.Worker.start_link(arg)
      # {MultiTranscription.Worker, arg},
      # Start to serve requests, typically the last entry
      MultiTranscriptionWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MultiTranscription.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MultiTranscriptionWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
