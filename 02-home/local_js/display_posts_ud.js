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
                const responsesDiv = document.getElementById(`responses-${postId}`);
                const comments = await fetchComments(postId);
                displayComments(responsesDiv, comments);
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

function displayComments(container, comments) {
    container.innerHTML = '';
    comments.forEach(comment => {
        const commentElement = document.createElement('div');
        commentElement.classList.add('comment');
        commentElement.innerHTML = `
            <p class="comment-content">${comment.comm_text}</p>
            <span class="comment-date">${new Date(comment.time_born).toLocaleDateString()}</span>
        `;
        container.appendChild(commentElement);
    });
}

async function postComment(postId, content) {
    try {
        const response = await fetch('/02-home/local_php/submit_comment.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ post_id: postId, content: content })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error posting comment:', error);
    }
}

document.addEventListener('DOMContentLoaded', fetchPosts);