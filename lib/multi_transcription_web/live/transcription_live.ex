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

  def render(assigns) do
    ~H"""
    <div id="transcription-room" phx-hook="Transcription">
      <h1>Transcription Room</h1>
      <ul>
        <%= for {timestamp, transcription} <- @transcriptions do %>
          <li><strong><%= timestamp %>:</strong> <%= transcription %></li>
        <% end %>
      </ul>
      <form>
        <input type="file" id="audio-upload" name="audio" accept=".mp3" phx-hook="AudioUpload" />
      </form>
    </div>
    """
  end
end
