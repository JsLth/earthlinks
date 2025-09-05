import { showToast, removeToast } from './showToast.js';
import { liveCounter } from './counter.js';
import { renderPalette } from './renderPalette.js'
import { togglePassword } from './togglePassword.js'
import { removeTooltip } from './tooltips.js'

window.renderPalette = renderPalette;
window.togglePassword = togglePassword;

export {
  showToast,
  removeToast,
  liveCounter,
  renderPalette,
  togglePassword,
  removeTooltip
}
