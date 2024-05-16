defmodule MultiTranscriptionWeb.TranscriptionLive do
  use MultiTranscriptionWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: MultiTranscriptionWeb.Endpoint.subscribe("transcription:lobby")
    {:ok, assign(socket, transcriptions: [])}
  end

  def handle_event("new_transcription", %{"transcription" => transcription}, socket) do
    transcriptions = [{DateTime.utc_now(), transcription} | socket.assigns.transcriptions]
    {:noreply, assign(socket, transcriptions: transcriptions)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: "transcription:lobby",
          event: "new_transcription",
          payload: %{"timestamp" => timestamp, "transcription" => transcription}
        },
        socket
      ) do
    transcriptions = [{timestamp, transcription} | socket.assigns.transcriptions]
    {:noreply, assign(socket, transcriptions: transcriptions)}
  end

  # def handle_info(message, socket) do
  #   IO.inspect(message, label: "Unmatched handle_info")
  #   {:noreply, socket}
  # end

  def render(assigns) do
    ~H"""
    <div id="transcription-room" phx-hook="Transcription">
      <h1>Transcription Room</h1>
      <ul>
        <%= for {timestamp, transcription} <- @transcriptions do %>
          <li><strong><%= timestamp %>:</strong> <%= transcription %></li>
        <% end %>
      </ul>
      <button id="start_recording" phx-hook="Transcription">Start Recording</button>
      <button id="stop_recording" phx-hook="Transcription">Stop Recording</button>
    </div>
    """
  end
end
