document.addEventListener('DOMContentLoaded', fetchPostsUd);
document.addEventListener('DOMContentLoaded', fetchPostsAdmin);

async function fetchPostsUd() {
    try {
        const response = await fetch('/02-home/local_php/get_posts_ud.php', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const postsUd = await response.json();
        console.log('Posts fetched successfully:', postsUd);
        displayPostsUd(postsUd);
    } catch (error) {
        console.error('Error fetching posts:', error);
    }
}

async function fetchPostsAdmin() {
    try {
        const response = await fetch('/02-home/local_php/get_posts_admn.php', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const postsAdmin = await response.json();
        console.log('Posts fetched successfully:', postsAdmin);
        displayPostsAdmin(postsAdmin);
    } catch (error) {
        console.error('Error fetching posts:', error);
    }
}

function displayPostsAdmin(posts) {
    const postContainer = document.getElementById('admin-posts-container');
    postContainer.innerHTML = '';

    posts.forEach(post => {
        const postElement = document.createElement('div');
        postElement.classList.add('post');
        postElement.innerHTML = `
            <div class="post-author">${post.nome} ${post.cognome}</div>
            <h3 class="post-title">${post.title} <span class="post-tag-prova">Tag</span></h3>
            <p class="post-content">${post.ttext}</p>
            <span class="post-date">${new Date(post.time_born).toLocaleDateString()}</span>
            <button type="button" class="toggle-comments" data-post-id="${post.post_id}">Commenti</button>
            <div class="responses" id="responses-${post.post_id}" style="display:none;"></div>
            <form class="response-form">
                <input type="text" placeholder="Aggiungi una risposta..." class="response-input">
                <button type="button" class="response-button" data-post-id="${post.post_id}">Rispondi</button>
            </form>
        `;
        postContainer.appendChild(postElement);
    });

    postContainer.addEventListener('click', gestoreClick);
}

function displayPostsUd(posts) {
    const postContainer = document.getElementById('user-posts-container');
    postContainer.innerHTML = '';

    posts.forEach(post => {
        const postElement = document.createElement('div');
        postElement.classList.add('post');
        postElement.innerHTML = `
            <h3 class="post-author">${post.nome} ${post.cognome}</h3>
            <h4 class="post-title">${post.title} <span class="post-tag-prova">Tag</span></h4>
            <p class="post-content">${post.ttext}</p>
            <span class="post-date">${new Date(post.time_born).toLocaleDateString()}</span>
            <button type="button" class="toggle-comments" data-post-id="${post.post_id}">Commenti</button>
            <div class="responses" id="responses-${post.post_id}" style="display:none;"></div>
            <form class="response-form">
                <input type="text" placeholder="Aggiungi una risposta..." class="response-input">
                <button type="button" class="response-button" data-post-id="${post.post_id}">Rispondi</button>
            </form>
        `;
        postContainer.appendChild(postElement);
    });

    postContainer.addEventListener('click', gestoreClick);
}

async function gestoreClick(event) {
    if (event.target.classList.contains('toggle-comments')) {
        const postId = event.target.dataset.postId;
        const responsesDiv = document.getElementById(`responses-${postId}`);
        if (responsesDiv.style.display === 'none') {
            const threads = await fetchThread(postId);
            displayThreads(responsesDiv, threads);
            responsesDiv.style.display = 'block';
        } else {
            responsesDiv.style.display = 'none';
        }
    }

    if (event.target.classList.contains('response-button')) {
        const postId = event.target.dataset.postId;
        const responseInput = event.target.previousElementSibling;
        const responseText = responseInput.value;
        if (responseText) {
            await postThread(postId, responseText);
            responseInput.value = '';
            const responsesDiv = document.getElementById(`responses-${postId}`);
            const threads = await fetchThread(postId);
            displayThreads(responsesDiv, threads);
        }
    }

    if (event.target.classList.contains('toggle-thread-comments')) {
        const threadId = event.target.dataset.threadId;
        const commentsDiv = document.getElementById(`comments-${threadId}`);
        if (commentsDiv.style.display === 'none') {
            const comments = await fetchThreadComments(threadId);
            displayComments(commentsDiv, comments);
            commentsDiv.style.display = 'block';
        } else {
            commentsDiv.style.display = 'none';
        }
    }

    if (event.target.classList.contains('comment-button')) {
        const threadId = event.target.dataset.threadId;
        const commentInput = event.target.previousElementSibling;
        const commentText = commentInput.value;
        if (commentText) {
            await postComment(threadId, commentText);
            commentInput.value = '';
        }
    }
}

async function fetchThread(postId) {
    try {
        const response = await fetch(`/02-home/local_php/get_comments.php?post_id=${postId}`);
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
    container.innerHTML = '';
    threads.forEach(thread => {
        const threadElement = document.createElement('div');
        threadElement.classList.add('thread');
        threadElement.innerHTML = `
            <h5 class="comment-author">${thread.nome} ${thread.cognome}</h5>
            <p class="thread-content">${thread.comm_text}</p>
            <span class="thread-date">${new Date(thread.time_born).toLocaleDateString()}</span>
            <button type="button" class="toggle-thread-comments" data-thread-id="${thread.thread_id}">Commenti</button>
            <div class="comments" id="comments-${thread.thread_id}" style="display:none;"></div>
            <form class="comment-form">
                <input type="text" placeholder="Aggiungi un commento..." class="comment-input">
                <button type="button" class="comment-button" data-thread-id="${thread.thread_id}">Commenta</button>
            </form>
        `;
        container.appendChild(threadElement);
    });
}

async function fetchThreadComments(threadId) {
    try {
        const response = await fetch(`/02-home/local_php/get_comments.php?thread_id=${threadId}`);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return await response.json();
    } catch (error) {
        console.error('Error fetching thread comments:', error);
        return [];
    }
}

function displayComments(container, comments) {
    container.innerHTML = '';
    comments.forEach(comment => {
        const commentElement = document.createElement('div');
        commentElement.classList.add('comment');
        commentElement.innerHTML = `
            <h5 class="comment-author">${comment.nome} ${comment.cognome}</h5>
            <p class="comment-content">${comment.comm_text}</p>
            <span class="comment-date">${new Date(comment.time_born).toLocaleDateString()}</span>
        `;
        container.appendChild(commentElement);
    });
}

async function postComment(threadId, content) {
    try {
        const response = await fetch('/02-home/local_php/submit_comment.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ thread_id: threadId, content: content })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const commentsDiv = document.getElementById(`comments-${threadId}`);
        const comments = await fetchThreadComments(threadId);
        displayComments(commentsDiv, comments);
        commentsDiv.style.display = 'block';

        return await response.json();
    } catch (error) {
        console.error('Error posting comment:', error);
    }
}

async function postThread(postId, content) {
    try {
        const response = await fetch('/02-home/local_php/submit_thread.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ post_id: postId, content: content })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const responsesDiv = document.getElementById(`responses-${postId}`);
        const threads = await fetchThread(postId);
        displayThreads(responsesDiv, threads);
        responsesDiv.style.display = 'block';

        return await response.json();
    } catch (error) {
        console.error('Error posting thread:', error);
    }
}
