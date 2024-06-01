function handleRequest(event, stato, action, reqId) {
  event.preventDefault();
  $.ajax({
    type: "POST",
    url: action,
    data: { req_id: reqId, stato: stato },
    success: function (response) {
      const form = $(`#${reqId}`);
      form.fadeOut(300, function () {
        form.remove();
      });
    },
  });
}
