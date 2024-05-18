import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
});
liveSocket.connect();

let socket = new Socket("/socket", { params: { token: window.userToken } });
socket.connect();

let channel = socket.channel("transcription:lobby", {});

channel
  .join()
  .receive("ok", (resp) => {
    console.log("Joined successfully", resp);
  })
  .receive("error", (resp) => {
    console.log("Unable to join", resp);
  });

let Transcription = {
  mounted() {
    this.handleEvent("new_transcription", ({ transcription }) => {
      let list = document.getElementById("transcriptions");
      let listItem = document.createElement("li");
      listItem.innerHTML = `<strong>${new Date().toLocaleTimeString()}:</strong> ${transcription}`;
      list.appendChild(listItem);
    });
  },
};

let AudioUpload = {
  mounted() {
    this.el.addEventListener("change", (event) => {
      let file = event.target.files[0];
      let formData = new FormData();
      formData.append("audio", file);

      fetch("/upload_audio", {
        method: "POST",
        body: formData,
        headers: {
          "X-CSRF-Token": csrfToken,
        },
      })
        .then((response) => response.json())
        .then((data) => {
          console.log("File uploaded successfully", data);
        })
        .catch((error) => {
          console.error("Error uploading file:", error);
        });
    });
  },
};

let Hooks = {
  Transcription,
  AudioUpload,
};

export { Hooks };
