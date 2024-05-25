document.addEventListener('DOMContentLoaded', fetchPosts);

async function fetchPosts() {
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

        const posts = await response.json();
        console.log('Posts fetched successfully:', posts);
        displayPosts(posts);
    } catch (error) {
        console.error('Error fetching posts:', error);
    }
}

function displayPosts(posts) {
    const postContainer = document.getElementById('user-posts-container');
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

    document.querySelectorAll('.toggle-comments').forEach(button => {
        button.addEventListener('click', async function() {
            const postId = this.dataset.postId;
            const responsesDiv = document.getElementById(`responses-${postId}`);
            if (responsesDiv.style.display === 'none') {
                const threads = await fetchComments(postId);
                displayThreads(responsesDiv, threads);
                responsesDiv.style.display = 'block';
            } else {
                responsesDiv.style.display = 'none';
            }
        });
    });

    document.querySelectorAll('.response-button').forEach(button => {
        button.addEventListener('click', async function() {
            const postId = this.dataset.postId;
            const responseInput = this.previousElementSibling;
            const responseText = responseInput.value;
            if (responseText) {
                await postComment(postId, responseText);
                responseInput.value = '';
                const responsesDiv = document.getElementById(`responses-${postId}`);
                const threads = await fetchComments(postId);
                displayThreads(responsesDiv, threads);
            }
        });
    });
}

async function fetchComments(postId) {
    try {
        const response = await fetch(`/02-home/local_php/get_comments.php?post_id=${postId}`);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return await response.json();
    } catch (error) {
        console.error('Error fetching comments:', error);
        return [];
    }
}

function displayThreads(container, threads) {
    container.innerHTML = '';
    threads.forEach(thread => {
        const threadElement = document.createElement('div');
        threadElement.classList.add('thread');
        threadElement.innerHTML = `
            <span class="comment-author">${thread.nome} ${thread.cognome}</span>
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

        document.querySelectorAll('.toggle-thread-comments').forEach(button => {
            button.addEventListener('click', async function() {
                const threadId = this.dataset.threadId;
                const commentsDiv = document.getElementById(`comments-${threadId}`);
                if (commentsDiv.style.display === 'none') {
                    const comments = await fetchThreadComments(threadId);
                    displayComments(commentsDiv, comments);
                    commentsDiv.style.display = 'block';
                } else {
                    commentsDiv.style.display = 'none';
                }
            });
        });

        document.querySelectorAll('.comment-button').forEach(button => {
            button.addEventListener('click', async function() {
                const threadId = this.dataset.threadId;
                const commentInput = this.previousElementSibling;
                const commentText = commentInput.value;
                if (commentText) {
                    await postComment(threadId, commentText, true);
                    commentInput.value = '';
                    const commentsDiv = document.getElementById(`comments-${threadId}`);
                    const comments = await fetchThreadComments(threadId);
                    displayComments(commentsDiv, comments);
                }
            });
        });
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
            <span class="comment-author">${comment.nome} ${comment.cognome}</span>
            <p class="comment-content">${comment.comm_text}</p>
            <span class="comment-date">${new Date(comment.time_born).toLocaleDateString()}</span>
        `;
        container.appendChild(commentElement);
    });
}

async function postComment(id, content, isThreadComment = false) {
    try {
        const response = await fetch('/02-home/local_php/submit_comment.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ id: id, content: content, isThreadComment: isThreadComment })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error posting comment:', error);
    }
}
