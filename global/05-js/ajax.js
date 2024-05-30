function handleRequest(event, action, reqId) {
  event.preventDefault();
  $.ajax({
    type: "POST",
    url: "./global/04-php/request_update.php",
    data: { req_id: reqId, stato: action },
    success: function (response) {
      const form = $(`#${reqId}`);
      form.fadeOut(300, function () {
        form.remove();
      });
    },
  });
}
