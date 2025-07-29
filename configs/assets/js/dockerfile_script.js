// Copy to clipboard functionality
function copyToClipboard() {
    const dockerfileContent = document.getElementById('dockerfileContent');
    const textArea = document.createElement('textarea');
    textArea.value = dockerfileContent.textContent;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand('copy');
    document.body.removeChild(textArea);
    
    // Show feedback
    const btn = event.target.closest('button');
    const originalHTML = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-check me-1"></i>Copied!';
    btn.classList.add('btn-success');
    btn.classList.remove('btn-outline-light');
    
    setTimeout(() => {
        btn.innerHTML = originalHTML;
        btn.classList.remove('btn-success');
        btn.classList.add('btn-outline-light');
    }, 2000);
}

function downloadDockerfile() {
    var content = document.getElementById('dockerfileContent').innerText;
    var blob = new Blob([content], { type: 'application/octet-stream' });
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url;
    a.download = 'Dockerfile';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

// Form validation
document.addEventListener('DOMContentLoaded', function() {
    const form = document.querySelector('form');
    const portInput = document.getElementById('portNumber');
    
    portInput.addEventListener('input', function() {
        const port = parseInt(this.value);
        if (port < 1 || port > 65535) {
            this.setCustomValidity('Port must be between 1 and 65535');
        } else {
            this.setCustomValidity('');
        }
    });
    
    form.addEventListener('submit', function(e) {
        const appName = document.getElementById('appName').value.trim();
        const port = parseInt(document.getElementById('portNumber').value);
        
        if (!appName) {
            e.preventDefault();
            alert('Application name is required');
            return;
        }
        
        if (!port || port < 1 || port > 65535) {
            e.preventDefault();
            alert('Please enter a valid port number (1-65535)');
            return;
        }
    });

   
});