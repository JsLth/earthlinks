export function showToast(options) {
  const toastEl = document.createElement('div');
  toastEl.className = `toast align-items-center`;
  toastEl.setAttribute('role', 'alert');
  toastEl.setAttribute('aria-live', 'assertive');
  toastEl.setAttribute('aria-atomic', 'true');
  let toastHTML;

  if (options.id) {
    toastEl.id = options.id;
  }

  if (options.layout === 'minimal') {
    toastHTML = `
      <div class='d-flex'>
        <div class='toast-body'>${options.message}</div>
        <button type='button' class='btn-close me-2 m-auto' data-bs-dismiss='toast' aria-label='Close'></button>
      </div>
    `
  } else if (options.layout === 'standard') {
    toastHTML = `
      <div class='toast-header'>
        ${options.icon}
        <span class='toast-spacer'><span class='divider'></span></span>
        <strong class='me-auto'>${options.title}</strong>
        <button type='button' class='btn-close' data-bs-dismiss='toast' aria-label='Close'></button>
      </div>
      <div class='toast-body'>${options.message}</div>
    `
  } else if (options.layout === 'dialog') {
    toastHTML = `
      <div class='toast-header'>
        ${options.icon}
        <span class='toast-spacer'><span class='divider'></span></span>
        <strong class='me-auto'>${options.title}</strong>
        <button type='button' class='btn-close' data-bs-dismiss='toast' aria-label='Close'></button>
      </div>
      <div class='toast-body'>
        ${options.message}
        <button type='button' class='btn btn-success btn-sm'>Confirm</button>
        <button type='button' class='btn btn-danger btn-sm'>Cancel</button>
      </div>
    `
  }
  
  toastEl.innerHTML = toastHTML
  const container = document.getElementById('toast-container');
  
  if (options.position) {
    container.classList.add(...options.position.split(' '));
  }
  
  container.appendChild(toastEl);
  
  const toastOptions = {
    animation: options.animation ?? true,
    autohide: options.autohide ?? true,
    delay: options.delay || 4000
  }
  
  const bsToast = new bootstrap.Toast(toastEl, toastOptions);
  bsToast.show();
}


export function removeToast(id) {
  const toastEl = document.getElementById(id);
  
  if (toastEl) {
    const toastInstance = bootstrap.Toast.getInstance(toastEl);
    
    if (toastInstance) {
      toastInstance.hide();
    }
    
    toastEl.remove();
  }
}


Shiny.addCustomMessageHandler('show-toast', function(data) {
  showToast(data);
})


Shiny.addCustomMessageHandler('remove-toast', function(id) {
  removeToast(id);
})