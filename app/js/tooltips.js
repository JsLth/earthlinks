export function removeTooltip(id) {
    var el = document.getElementById(id);
    if(el && bootstrap.Tooltip.getInstance(el)) {
        bootstrap.Tooltip.getInstance(el).dispose();
    }
}


Shiny.addCustomMessageHandler('remove-tooltip', function(id) {
    removeTooltip(id)
})