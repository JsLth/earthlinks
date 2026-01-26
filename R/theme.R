earthlinks_theme <- function() {
  bslib::bs_theme(
    primary = "#d20064",
    secondary = "#1E8CC8",
    success = "#198754",
    info = "#0dcaf0",
    warning = "#ffc107",
    danger = "#dc3545",
    base_font = "Source Sans Pro"
  ) |>
    # modal theming that aligns more closely with BS5 docs
    bslib::bs_add_rules("
    /* make toast background opaque */
    .toast {
      --bs-toast-header-bg: rgba(var(--bs-body-bg-rgb), 1) !important;
      --bs-toast-bg: rgba(var(--bs-body-bg-rgb), 1) !important;
    }
    
    /* enforce denser modal styling */
    .modal-footer, .modal-body {
      padding: calc((var(--bs-modal-padding) - var(--bs-modal-footer-gap) * .5)) !important
    }
    
    .modal-content {
      border-width: var(--bs-modal-border-width, 1px);
      border-color: var(--bs-modal-border-color, rgba(0, 0, 0, 0.2));
      border-radius: var(--bs-modal-border-radius, 0.3rem);
    }
    
    .modal {
      --bs-modal-header-border-width: 1px;
      --bs-modal-header-border-color: #dee2e6;
      --bs-modal-header-padding: 0.5rem 1rem;
      --bs-modal-inner-border-radius: calc(0.3rem - 1px);
      --bs-modal-border-width: 1px;
      --bs-modal-border-color: rgba(0, 0, 0, 0.2);
      --bs-modal-border-radius: 0.3rem;
      --bs-modal-width: 700px !important;
    }

    /* remove button borders */
    .accordion {
      --bs-accordion-btn-focus-box-shadow: rgba(0, 0, 0, 0);
    }

    .btn {
      --bs-btn-box-shadow: rgba(0, 0, 0, 0);
      --bs-btn-focus-box-shadow: rgba(0, 0, 0, 0);
    }

    .btn-close {
      --bs-btn-close-focus-shadow: rgba(0, 0, 0, 0)
    }
    
    .vscomp-toggle-button {
      border: var(--bs-border-width) solid #8D959E !important;
      border-radius: var(--bs-border-radius);
      background-color: var(--bs-body-bg) !important;
      transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
      background-clip: padding-box;
      color: var(--bs-body-color) ;
      line-height: 1.5;
      font-weight: 400;
    }
    
    .vscomp-wrapper:focus .vscomp-toggle-button {
      color: var(--bs-body-color);
      background-color: var(--bs-body-bg) !important;
      border-color: #e980b2 !important;
      outline: 0;
      box-shadow: 0 0 0 .25rem rgba(210, 0, 100, 0.25) !important;
    }
  ")
}