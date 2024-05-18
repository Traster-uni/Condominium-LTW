const toggleCommentsButtons = document.querySelectorAll('.toggle-comments');

toggleCommentsButtons.forEach(button => {
    button.addEventListener('click', event => {
        const parentPost = event.target.closest('.post');
        const responsesDiv = parentPost.querySelector('.responses');
        if (responsesDiv.style.display === 'none' || responsesDiv.style.display === '') {
            responsesDiv.style.display = 'block';
        } else {
            responsesDiv.style.display = 'none';
        }
    });
});