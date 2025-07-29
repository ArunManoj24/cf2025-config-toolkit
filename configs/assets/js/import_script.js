
 document.getElementById('configFile').addEventListener('change', function(e) {
    const label = document.getElementById('fileLabel');
    const fileName = e.target.files[0] ? e.target.files[0].name : '';

    if (fileName) {
    label.innerHTML = `
        <i class="fas fa-file-check fa-2x mb-2 text-success"></i><br>
        <span class="text-success fw-bold">${fileName}</span><br>
        <small class="text-muted">Click to select a different file</small>
    `;
    label.classList.add('file-selected');
    } else {
    label.innerHTML = `
        <i class="fas fa-cloud-upload-alt fa-2x mb-2 text-muted"></i><br>
        <span class="text-muted">Click to select JSON configuration file</span><br>
        <small class="text-muted">Only .json files are accepted</small>
    `;
    label.classList.remove('file-selected');
    }
});

// Form submission loading state
document.getElementById('importForm').addEventListener('submit', function(e) {
    const submitBtn = document.getElementById('submitBtn');
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing...';
    submitBtn.disabled = true;
});

// Auto-dismiss alerts after 10 seconds
// setTimeout(function() {
//     const alerts = document.querySelectorAll('.alert');
//     alerts.forEach(alert => {
//         const bsAlert = new bootstrap.Alert(alert);
//         bsAlert.close();
//     });
// }, 10000);