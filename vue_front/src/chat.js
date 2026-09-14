const sidebarToggleCheckbox = document.getElementById('sidebar-toggle')
const sidebarToggleLabel = document.getElementById('sidebar-toggle-label')

sidebarToggleCheckbox.addEventListener('change', () => {
    sidebarToggleLabel.setAttribute('aria-expanded', String(sidebarToggleCheckbox.checked))
})