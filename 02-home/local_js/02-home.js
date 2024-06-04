function showTab(tabId) {
  // Nascondi tutti i tab
  var tabs = document.getElementsByClassName("tabcontent");
  for (var i = 0; i < tabs.length; i++) {
    tabs[i].style.display = "none";
  }

  // Mostra il tab selezionato
  var selectedTab = document.getElementById(tabId);
  if (selectedTab) {
    selectedTab.style.display = "block";
  }
}
