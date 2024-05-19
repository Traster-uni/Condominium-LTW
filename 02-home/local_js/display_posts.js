async function fetchPosts() {
    const response = await fetch('02-home/local_php/get_posts.php', {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    });

    const posts = await response.json();
    displayPosts(posts);
}

function displayPosts(posts) {
    const postContainer = document.getElementById('tab-admin');
    postContainer.innerHTML = '';

    posts.forEach(post => {
        const postElement = document.createElement('div');
        postElement.classList.add('post');
        postElement.innerHTML = `
            <h3 class="post-title">${post.title} <span class="post-tag">Tag</span></h3>
            <p class="post-content">${post.ttext}</p>
            <span class="post-date">${new Date(post.time_born).toLocaleDateString()}</span>
            <button type="button" class="toggle-comments">Commenti</button>
            <div class="responses" style="display:none;"></div>
            <form class="response-form">
                <input type="text" placeholder="Aggiungi una risposta..." class="response-input">
                <button type="button" class="response-button" data-post-id="${post.post_id}">Rispondi</button>
            </form>
        `;
        postContainer.appendChild(postElement);
    });
}