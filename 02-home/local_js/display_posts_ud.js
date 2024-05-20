async function fetchPosts() {
    const response = await fetch('/02-home/local_php/get_posts_ud.php', {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    });

    const posts = await response.json();
    displayPosts(posts);
}

function displayPosts(posts) {
    const postContainer = document.getElementById('user-posts-container');
    postContainer.innerHTML = '';

    posts.forEach(post => {
        const postElement = document.createElement('div');
        postElement.classList.add('post');
        postElement.innerHTML = `
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
            const responsesDiv = document.getElementById('responses-${postId}');
            if (responsesDiv.style.display === 'none') {
                const comments = await fetchComments(postId);
                displayComments(responsesDiv, comments);
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
                const responsesDiv = document.getElementById('responses-${postId}');
                const comments = await fetchComments(postId);
                displayComments(responsesDiv, comments);
            }
        });
    });
}

/* async function fetchComments(postId) {
    const response = await fetch('/02-home/local_php/get_comments.php?post_id=${postId}', {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    });
    return await response.json();
}

function displayComments(responsesDiv, comments) {
    responsesDiv.innerHTML = '';
    comments.forEach(comment => {
        const commentElement = document.createElement('div');
        commentElement.classList.add('comment');
        commentElement.innerHTML = `
            <p>${comment.content}</p>
            <span class="comment-date">${new Date(comment.time_born).toLocaleDateString()}</span>
            <form class="response-form">
                <input type="text" placeholder="Aggiungi una risposta..." class="response-input">
                <button type="button" class="response-button" data-comment-id="${comment.thread_id}">Rispondi</button>
            </form>
            <div class="responses" style="display:none;" id="responses-${comment.thread_id}"></div>
        `;
        responsesDiv.appendChild(commentElement);

        const responsesDivNested = commentElement.querySelector('#responses-${comment.thread_id}');
        const responsesNested = comment.responses || [];
        displayComments(responsesDivNested, responsesNested);
    });
}

async function postComment(postId, commentText, parentId = null) {
    const body = { post_id: postId, content: commentText };
    if (parentId !== null) {
        body.parent_id = parentId;
    }
    await fetch('/02-home/local_php/post_comment.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(body)
    });
} */

document.addEventListener('DOMContentLoaded', fetchPosts);