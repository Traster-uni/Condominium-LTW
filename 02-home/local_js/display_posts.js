document.addEventListener("DOMContentLoaded", async () => {
  await fetchPosts();
  await checkUserRole();
});

async function checkUserRole() {
  try {
    const response = await fetch("/global/04-php/get_user_role.php", {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    console.log("User role fetched successfully:", data);

    if (data.role === "admin") {
      enableAdminPosting();
      enableAdminFeatures();
    } else {
      enableUserPosting();
    }
  } catch (error) {
    console.error("Error fetching user role:", error);
  }
}

function enableAdminPosting() {
  const adminPostContainer = document.getElementById("admin-form-container");
  if (adminPostContainer) {
    adminPostContainer.innerHTML = `
            <form action="./02-home/local_php/submit_post_admin.php" class="post-form" id="admin-post-form" method="post">
                <input type="text" id="admin-post-title" name="admin-post-title" placeholder="Titolo del post" required>
                <select class="tags" name="tags" id="tags" required>
                    <option value="">tags</option>
                    <option value="Evento">Evento (con data)</option>
                    <option value="Riunione">Riunione (con data)</option>
                    <option value="Avvertenze">Avvertenze (con data)</option>
                    <option value="Danni spazi comuni">Danni spazi comuni</option>
                    <option value="Danno palazzina">Danno palazzina</option>
                    <option value="Lamentela">Lamentela</option>
                    <option value="Proposta condominio">Proposta condominio</option>
                </select>
                <input type="datetime-local" id="event-datetime" name="event-datetime" style="margin-right: 20px"/>
                <textarea id="admin-post-content" name="admin-post-content" placeholder="Scrivi qualcosa..."></textarea>
                <input type="submit" value="Invia">
            </form>
        `;
  }
}

function enableUserPosting() {
  const userPostContainer = document.getElementById("user-form-container");
  if (userPostContainer) {
    userPostContainer.innerHTML = `
            <form action="./02-home/local_php/submit_post_ud.php" class="post-form" id="user-post-form" method="post">
                <input type="text" id="ud-post-title" name="ud-post-title" placeholder="Titolo del post" required>
                <select class="tags" name="tags" id="tags" required>
                    <option value="">tags</option>
                    <option value="Danni spazi comuni">Danni spazi comuni</option>
                    <option value="Danno palazzina">Danno palazzina</option>
                    <option value="Lamentela">Lamentela</option>
                    <option value="Proposta condomino">Proposta condomino</option>
                </select>
                <textarea id="ud-post-content" name="ud-post-content" placeholder="Scrivi qualcosa..." required></textarea>
                <input type="submit" value="Invia">
            </form>
        `;
  }
}

async function fetchPosts() {
  try {
    const response = await fetch("/02-home/local_php/get_post.php", {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const posts = await response.json();
    console.log("Posts fetched successfully:", posts);
    displayPosts(posts);
  } catch (error) {
    console.error("Error fetching posts:", error);
  }
}

function displayPosts(posts) {
  const userPosts = posts.filter((post) => post.bb_name === "general");
  const adminPosts = posts.filter((post) => post.bb_name === "admin");

  displayPostsUd(userPosts);
  displayPostsAdmin(adminPosts);
}

function displayPostsAdmin(posts) {
  const postContainer = document.getElementById("admin-posts-container");
  postContainer.innerHTML = "";

  if (posts.length === 0) {
    postContainer.innerHTML = "<p>Nessun post presente</p>";
    return;
  }

  posts.forEach((post) => {
    const postElement = document.createElement("div");
    postElement.classList.add("post");
    postElement.dataset.postId = post.post_id;
    postElement.dataset.offComments = post.off_comments;
    postElement.dataset.bbName = post.bb_name;

    const time_born = new Date(post.time_born);
    const data_pubblicazione = new Intl.DateTimeFormat("en-GB", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
    }).format(time_born);

    let data_evento;
    if (post.time_event != null) {
      const time_event = new Date(post.time_event);
      const data = new Intl.DateTimeFormat("en-GB", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
      }).format(time_event);
      const ora = time_event.toLocaleTimeString("en-GB", {
        hour: "2-digit",
        minute: "2-digit",
        hour12: false, // use 24-hour time format
      });
      data_evento = `(${data}, ${ora})`;
    } else {
      data_evento = "";
    }

    if (post.off_comments === "f") {
      postElement.innerHTML = `
                <div class="author-time">
                <p class="post-author">${post.nome} ${post.cognome}</p>
                <span class="post-date">${data_pubblicazione}</span>
                </div>
                <h5 class="post-title">
                ${post.title}
                ${data_evento}
                <span class="post-tag-prova">${post.name_tag}</span>
                </h5>
                <p class="post-content">${post.ttext}</p>
                <button type="button" class="toggle-comments" data-post-id="${post.post_id}" data-bb-name="${post.bb_name}">Commenti</button>
                <div class="responses" id="responses-${post.post_id}" style="display:none;"></div>
                <form class="response-form">
                    <input type="text" placeholder="Aggiungi una risposta..." class="response-input">
                    <button type="button" class="response-button" data-post-id="${post.post_id}" data-bb-name="${post.bb_name}">Rispondi</button>
                </form>
            `;
    } else {
      postElement.innerHTML = `
                <div class="author-time">
                <p class="post-author">${post.nome} ${post.cognome}</p>
                <span class="post-date">${data_pubblicazione}</span>
                </div>
                <h5 class="post-title">
                ${post.title}
                ${data_evento}
                <span class="post-tag-prova">${post.name_tag}</span>
                </h5>
                <p class="post-content">${post.ttext}</p>
                <div class="responses" id="responses-${post.post_id}" style="display:none;"></div>
            `;
    }
    postContainer.appendChild(postElement);
  });

  postContainer.addEventListener("click", gestoreClick);
}

function displayPostsUd(posts) {
  const postContainer = document.getElementById("user-posts-container");
  postContainer.innerHTML = "";

  if (posts.length === 0) {
    postContainer.innerHTML = "<p>Nessun post presente</p>";
    return;
  }

  posts.forEach((post) => {
    const postElement = document.createElement("div");
    postElement.classList.add("post");
    postElement.dataset.postId = post.post_id;
    postElement.dataset.offComments = post.off_comments;
    postElement.dataset.bbName = post.bb_name;
    const time_born = new Date(post.time_born);
    const data_pubblicazione = new Intl.DateTimeFormat("en-GB", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
    }).format(time_born);

    if (post.off_comments === "f") {
      postElement.innerHTML = `
                <div class="author-time">
                <p class="post-author">${post.nome} ${post.cognome}</p>
                <span class="post-date">${data_pubblicazione}</span>
                </div>
                <h5 class="post-title">${post.title} <span class="post-tag-prova">${post.name_tag}</span></h5>
                <p class="post-content">${post.ttext}</p>
                <button type="button" class="toggle-comments" data-post-id="${post.post_id}" data-bb-name="${post.bb_name}">Commenti</button>
                <div class="responses" id="responses-${post.post_id}" style="display:none;"></div>
                <form class="response-form">
                    <input type="text" placeholder="Aggiungi una risposta..." class="response-input">
                    <button type="button" class="response-button" data-post-id="${post.post_id}" data-bb-name="${post.bb_name}">Rispondi</button>
                </form>
            `;
    } else {
      postElement.innerHTML = `
                <div class="author-time">
                <p class="post-author">${post.nome} ${post.cognome}</p>
                <span class="post-date">${data_pubblicazione}</span>
                </div>
                <h5 class="post-title">${post.title} <span class="post-tag-prova">${post.name_tag}</span></h5>
                <p class="post-content">${post.ttext}</p>
                <div class="responses" id="responses-${post.post_id}" style="display:none;"></div>
            `;
    }
    postContainer.appendChild(postElement);
  });

  postContainer.addEventListener("click", gestoreClick);
}

async function gestoreClick(event) {
    if (event.target.classList.contains('toggle-comments')) {
        const postId = event.target.dataset.postId;
        const type = event.target.dataset.bbName;
        console.log(type);
        const responsesDiv = document.getElementById(`responses-${postId}`);
        if (responsesDiv.style.display === 'none') {
            const threads = await fetchThread(postId, type);
            displayThreads(responsesDiv, threads);
            responsesDiv.style.display = 'block';
        } else {
            responsesDiv.style.display = 'none';
        }
    }

    if (event.target.classList.contains('response-button')) {
        const postId = event.target.dataset.postId;
        const type = event.target.dataset.bbName;
        const responseInput = event.target.previousElementSibling;
        const responseText = responseInput.value;
        if (responseText) {
            await postThread(postId, responseText, type);
            responseInput.value = '';
            const responsesDiv = document.getElementById(`responses-${postId}`);
            const threads = await fetchThread(postId, type);
            displayThreads(responsesDiv, threads);
        }
    }

  if (event.target.classList.contains("toggle-thread-comments")) {
    const threadId = event.target.dataset.threadId;
    const commentsDiv = document.getElementById(`comments-${threadId}`);
    if (commentsDiv.style.display === "none") {
      const comments = await fetchThreadComments(threadId);
      displayComments(commentsDiv, comments);
      commentsDiv.style.display = "block";
    } else {
      commentsDiv.style.display = "none";
    }
  }

  if (event.target.classList.contains("comment-button")) {
    const threadId = event.target.dataset.threadId;
    const commentInput = event.target.previousElementSibling;
    const commentText = commentInput.value;
    if (commentText) {
      await postComment(threadId, commentText);
      commentInput.value = "";
    }
  }
}

async function fetchThread(postId, type) {
    try {
        const response = await fetch(`/02-home/local_php/get_comments.php?post_id=${postId}&type=${type}`, {
            method: 'GET'
        });
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return await response.json();
    } catch (error) {
        console.error('Error fetching threads:', error);
        return [];
    }
}

function displayThreads(container, threads) {
  container.innerHTML = "";
  threads.forEach((thread) => {
    const threadElement = document.createElement("div");
    threadElement.classList.add("thread");
    threadElement.dataset.threadId = thread.thread_id;
    threadElement.innerHTML = `
            <h5 class="comment-author">${thread.nome} ${thread.cognome}</h5>
            <p class="thread-content">${thread.comm_text}</p>
            <span class="thread-date">${new Date(
              thread.time_born
            ).toLocaleDateString()}</span>
            <button type="button" class="toggle-thread-comments" data-thread-id="${
              thread.thread_id
            }" data-bb-name="${post.bb_name}">Commenti</button>
            <div class="comments" id="comments-${
              thread.thread_id
            }" style="display:none;"></div>
            <form class="comment-form">
                <input type="text" placeholder="Aggiungi un commento..." class="comment-input">
                <button type="button" class="comment-button" data-thread-id="${
                  thread.thread_id
                }" data-bb-name="${post.bb_name}">Commenta</button>
            </form>
        `;
    container.appendChild(threadElement);
  });
}

async function fetchThreadComments(threadId) {
    try {
        const response = await fetch(`/02-home/local_php/get_comments.php?thread_id=${threadId}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        ///////////////////
        console.log('Threads fetched successfully:', threadComments);
        return await response.json();
    } catch (error) {
        console.error('Error fetching thread comments:', error);
        return [];
    }
}

function displayComments(container, comments) {
  container.innerHTML = "";
  comments.forEach((comment) => {
    const commentElement = document.createElement("div");
    commentElement.classList.add("comment");
    commentElement.dataset.commentId = comment.comment_id;
    commentElement.innerHTML = `
            <h5 class="comment-author">${comment.nome} ${comment.cognome}</h5>
            <p class="comment-content">${comment.comm_text}</p>
            <span class="comment-date">${new Date(
              comment.time_born
            ).toLocaleDateString()}</span>
        `;
    container.appendChild(commentElement);
  });
}

async function postComment(threadId, content, type) {
    try {
        const response = await fetch('/02-home/local_php/submit_comment.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ thread_id: threadId, content: content, type: type })
        });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

        const commentsDiv = document.getElementById(`comments-${threadId}`);
        // const comments = await fetchThreadComments(threadId);
        displayComments(commentsDiv, comments);
        commentsDiv.style.display = 'block';

    return await response.json();
  } catch (error) {
    console.error("Error posting comment:", error);
  }
}

async function postThread(postId, content, type) {
    try {
        const response = await fetch('/02-home/local_php/submit_thread.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ post_id: postId, content: content, type: type })
        });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

        const responsesDiv = document.getElementById(`responses-${postId}`);
        const threads = await fetchThread(postId, type);
        displayThreads(responsesDiv, threads);
        responsesDiv.style.display = 'block';

    return await response.json();
  } catch (error) {
    console.error("Error posting thread:", error);
  }
}

function enableAdminFeatures() {
  // Mostra i controlli di moderazione per i post
  const postContainers = document.querySelectorAll(".post");
  postContainers.forEach((container) => {
    const deleteButton = document.createElement("button");
    deleteButton.textContent = "Elimina Post";
    deleteButton.classList.add("delete-post-button");
    deleteButton.dataset.postId = container.dataset.postId; // Aggiungi l'ID del post come attributo dei dati
    deleteButton.dataset.bbName = container.dataset.bbName;
    container.appendChild(deleteButton);
  });

  // Aggiungi gestore di eventi per eliminare i post
  postContainers.forEach((container) => {
    container.addEventListener("click", async (event) => {
      if (event.target.classList.contains("delete-post-button")) {
        const postId = event.target.dataset.postId;
        const type = event.target.dataset.bbName;
        await deletePost(postId, type);
      }
    });
  });

  // Enable/disable dei commenti
  postContainers.forEach((container) => {
    const toggleButton = document.createElement("button");
    const txt =
      container.dataset.offComments === "t"
        ? "Abilita commenti"
        : "Disabilita commenti";
    toggleButton.textContent = txt;
    toggleButton.classList.add("enable-disable-comment-button");
    toggleButton.dataset.postId = container.dataset.postId; // Aggiungi l'ID del post come attributo dei dati
    toggleButton.dataset.bbName = container.dataset.bbName;
    toggleButton.addEventListener("click", async (event) => {
      if (container.dataset.offComments === "t") {
        const postId = event.target.dataset.postId;
        const type = event.target.dataset.bbName;
        await enableDisableComment(postId, "enable", type);
      } else {
        const postId = event.target.dataset.postId;
        const type = event.target.dataset.bbName;
        await enableDisableComment(postId, "disable", type);
      }
    });
    container.appendChild(toggleButton);
  });
}

async function deletePost(postId, type) {
  try {
    // Chiedi conferma prima di procedere con l'eliminazione
    const confirmation = confirm("Sei sicuro di voler eliminare questo post?");
    if (!confirmation) {
      return; // L'admin ha annullato l'operazione di eliminazione
    }
    const response = await fetch(
      `/02-home/local_php/delete_post.php?post_id=${postId}&type=${type}`,
      {
        method: "DELETE",
      }
    );

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    // Rimuovi il post dalla UI dopo l'eliminazione
    const postContainer = document.querySelector(
      `.post[data-post-id="${postId}"][data-bb-name="${type}"]`
    );
    postContainer.remove();

    console.log("Post deleted successfully");
  } catch (error) {
    console.error("Error deleting post:", error);
  }
}

async function enableDisableComment(postId, action, type) {
  try {
    const confirmationMsg =
      action === "disable"
        ? "Sei sicuro di voler silenziare questo post?"
        : "Sei sicuro di voler abilitare i commenti su questo post?";
    const confirmation = confirm(confirmationMsg);

    if (!confirmation) {
      return; // L'admin ha annullato l'operazione
    }
    const response = await fetch(
      `/02-home/local_php/enable_disable_comment.php?post_id=${postId}&action=${action}&type=${type}`,
      {
        method: "GET",
      }
    );

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    // Aggiorna il post nella UI
    updatePostElement(postId, action, type);
  } catch (error) {
    console.error("Error disabling post:", error);
  }
}

function updatePostElement(postId, action, type) {
  const postElement = document.querySelector(
    `.post[data-post-id="${postId}"][data-bb-name="${type}"]`
  );
  const toggleButton = postElement.querySelector(
    ".enable-disable-comment-button"
  );
  const responsesDiv = postElement.querySelector(".responses");
  const responseForm = postElement.querySelector(".response-form");

  if (action === "disable") {
    postElement.dataset.offComments = "t";
    toggleButton.textContent = "Abilita commenti";
    if (responseForm) {
      responseForm.style.display = "none";
    }
  } else {
    postElement.dataset.offComments = "f";
    toggleButton.textContent = "Disabilita commenti";
    if (responseForm) {
      responseForm.style.display = "block";
    }
  }
}
