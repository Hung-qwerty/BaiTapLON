// QuanLyKho - main.js

// Tự động ẩn flash message sau 3 giây
document.addEventListener('DOMContentLoaded', function () {
    const flash = document.querySelector('.flash-msg');
    if (flash) setTimeout(() => flash.style.display = 'none', 3000);

    // Highlight active row khi click
    document.querySelectorAll('tbody tr').forEach(row => {
        row.addEventListener('click', function (e) {
            if (e.target.tagName === 'BUTTON' || e.target.tagName === 'A') return;
            document.querySelectorAll('tbody tr').forEach(r => r.style.background = '');
            this.style.background = '#eff6ff';
        });
    });

    // Confirm cho form delete
    document.querySelectorAll('form[data-confirm]').forEach(f => {
        f.addEventListener('submit', function (e) {
            if (!confirm(this.dataset.confirm)) e.preventDefault();
        });
    });
});
