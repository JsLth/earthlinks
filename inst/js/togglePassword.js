export function togglePassword(id, iconId) {
    var input = document.getElementById(id);
    var iconContainer = document.getElementById(iconId);
    var iconShow = iconContainer.getElementsByClassName('bi-eye')[0]
    var iconHide = iconContainer.getElementsByClassName('bi-eye-slash')[0]

    if (input.type === 'password') {
        input.type = 'text';
        iconShow.style.display = 'none';
        iconHide.style.display = '';
    } else {
        input.type = 'password';
        iconShow.style.display = '';
        iconHide.style.display = 'none';
    }
}
