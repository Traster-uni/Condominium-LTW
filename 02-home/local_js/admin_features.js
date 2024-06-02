async function checkUserRole() {
    try {
        // Fetch user role
        const response = await fetch('/global/04-php/get_user_role.php', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        console.log('User role fetched successfully:', data);

        if (data.role === 'admin') {
            enableAdminFeatures();
        }
    } catch (error) {
        console.error('Error fetching user role:', error);
    }
}

function enableAdminFeatures() {
    // Mostra i controlli di moderazione per i post
    const postContainers = document.querySelectorAll('.post');
    postContainers.forEach(container => {
        const deleteButton = document.createElement('button');
        deleteButton.textContent = 'Elimina Post';
        deleteButton.classList.add('delete-post-button');
        deleteButton.dataset.postId = container.dataset.postId; // Aggiungi l'ID del post come attributo dei dati
        deleteButton.dataset.bbName = container.dataset.bbName;
        container.appendChild(deleteButton);
    });

    // Mostra i controlli di moderazione per i thread
    const threadContainers = document.querySelectorAll('.thread');
    threadContainers.forEach(container => {
        const deleteButton = document.createElement('button');
        deleteButton.textContent = 'Elimina Thread';
        deleteButton.classList.add('delete-thread-button');
        deleteButton.dataset.threadId = container.dataset.threadId; // Aggiungi l'ID del thread come attributo dei dati
        deleteButton.dataset.bbName = container.dataset.bbName;
        container.appendChild(deleteButton);
    });

    // Mostra i controlli di moderazione per i commenti
    const commentContainers = document.querySelectorAll('.comment');
    commentContainers.forEach(container => {
        const deleteButton = document.createElement('button');
        deleteButton.textContent = 'Elimina Commento';
        deleteButton.classList.add('delete-comment-button');
        deleteButton.dataset.commentId = container.dataset.commentId; // Aggiungi l'ID del commento come attributo dei dati
        deleteButton.dataset.bbName = container.dataset.bbName;
        container.appendChild(deleteButton);
    });

    // Aggiungi gestore di eventi per eliminare i post
    postContainers.forEach(container => {
        container.addEventListener('click', async(event) => {
            if (event.target.classList.contains('delete-post-button')) {
                const postId = event.target.dataset.postId;
                const type = event.target.dataset.bbName;
                await deletePost(postId, type);
            }
        });
    });

    // Aggiungi gestore di eventi per eliminare i thread
    threadContainers.forEach(container => {
        container.addEventListener('click', async(event) => {
            if (event.target.classList.contains('delete-thread-button')) {
                const threadId = event.target.dataset.threadId;
                const type = event.target.dataset.bbName;
                await deleteThread(threadId);
            }
        });
    });

    // Aggiungi gestore di eventi per eliminare i commenti
    commentContainers.forEach(container => {
        container.addEventListener('click', async(event) => {
            if (event.target.classList.contains('delete-comment-button')) {
                const commentId = event.target.dataset.commentId;
                const type = event.target.dataset.bbName;
                await deleteComment(commentId);
            }
        });
    });
}

// Funzione per eleminiare un post con relativi thread e commenti
async function deletePost(postId, type) {
    try {
        const confirmation = confirm('Sei sicuro di voler eliminare questo post?');
        if (!confirmation) return; // Annulla l'eliminazione se l'utente clicca su "Annulla" nella conferma

        const response = await fetch(`/02-home/local_php/delete_post.php?post_id=${postId}&type=${type}`, {
            method: 'DELETE'
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        // Rimuovi il post dalla UI dopo l'eliminazione
        const postContainer = document.querySelector(`.post[data-post-id="${postId}"]`);
        postContainer.remove();

        console.log('Post deleted successfully');
    } catch (error) {
        console.error('Error deleting post:', error);
    }
}

// Funzione per eliminare un thread e i relativi commenti
async function deleteThread(threadId) {
    try {
        const confirmation = confirm('Sei sicuro di voler eliminare questo thread?');
        if (!confirmation) return; // Annulla l'eliminazione se l'utente clicca su "Annulla" nella conferma

        const response = await fetch(`/02-home/local_php/delete_thread.php?thread_id=${threadId}`, {
            method: 'DELETE'
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        // Rimuovi il thread dalla UI dopo l'eliminazione
        const threadContainer = document.querySelector(`.thread[data-thread-id="${threadId}"]`);
        threadContainer.remove();

        console.log('Thread deleted successfully');
    } catch (error) {
        console.error('Error deleting thread:', error);
    }
}

// Funzione per eliminare un commento specifico
async function deleteComment(commentId) {
    try {
        const confirmation = confirm('Sei sicuro di voler eliminare questo commento?');
        if (!confirmation) return; // Annulla l'eliminazione se l'utente clicca su "Annulla" nella conferma

        const response = await fetch(`/02-home/local_php/delete_comment.php?comment_id=${commentId}`, {
            method: 'DELETE'
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        // Rimuovi il commento dalla UI dopo l'eliminazione
        const commentContainer = document.querySelector(`.comment[data-comment-id="${commentId}"]`);
        commentContainer.remove();

        console.log('Comment deleted successfully');
    } catch (error) {
        console.error('Error deleting comment:', error);
    }
}