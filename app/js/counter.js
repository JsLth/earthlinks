export function liveCounter(startTime, options = {}) {
  const el = document.createElement('div');
  el.className = options.className || 'live-counter'
  
  const start = new Date(startTime);
  const update = () => {
    const now = new Date();
    const diff = Math.floor((now - start) / 1000)
    const hours = Math.floor(diff / 3600)
    const minutes = Math.floor((diff % 3600) / 60)
    const seconds = diff % 60
    
    let timeString;
    if (hours > 1) {
      timeString = `⏱️ Elapsed time: ${hours}h ${minutes}m ${seconds}s`;
    } else if (minutes > 1) {
      timeString = `⏱️ Elapsed time: ${minutes}m ${seconds}s`;
    } else {
      timeString = `⏱️ Elapsed time: ${seconds}s`;
    }
    
    el.textContent = timeString;
  }
  
  update();
  const interval = setInterval(update, 1000);
  
  const observer = new MutationObserver(() => {
    if (!document.body.contains(el)) clearInterval(interval);
  });
  
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
  
  console.log(el)
  return el;
}


function hydrateLiveCounters() {
  document.querySelectorAll('.live-counter[data-start]').forEach(el => {
    if (el.dataset.hydrated) return;
    const start = el.getAttribute('data-start');
    const liveEl = liveCounter(start);
    el.replaceWith(liveEl);
  });
}


document.addEventListener('DOMContentLoaded', () => {
  hydrateLiveCounters(); // do initial hydration

  const observer = new MutationObserver(hydrateLiveCounters);
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
});