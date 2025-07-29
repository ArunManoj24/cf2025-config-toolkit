document.addEventListener('DOMContentLoaded', function() {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function(tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
    
    const checkButton = document.getElementById('checkButton');
    if (checkButton) {
        checkButton.addEventListener('click', function() {
            const icon = this.querySelector('.fa-plug');
            if (icon) {
                icon.classList.remove('fa-plug');
                icon.classList.add('fa-spinner', 'fa-spin');
            }
            this.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Checking Connections...';
            this.disabled = true;
        });
    }
    
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('refresh') === 'true') {
        const rows = document.querySelectorAll('.datasource-row');
        rows.forEach((row, index) => {
            setTimeout(() => {
                row.style.backgroundColor = 'rgba(40, 167, 69, 0.1)';
                setTimeout(() => {
                    row.style.backgroundColor = '';
                }, 1000);
            }, index * 100);
        });
    }
});