document.addEventListener("turbo:load", function () {
  const toggleButton = document.getElementById("menu-toggle")
  const siteMenu = document.getElementById("site-menu")

  if (!toggleButton || !siteMenu) return

  function closeMenu() {
    siteMenu.hidden = true
    toggleButton.setAttribute("aria-expanded", "false")
  }

  function openMenu() {
    siteMenu.hidden = false
    toggleButton.setAttribute("aria-expanded", "true")
  }

  toggleButton.addEventListener("click", function () {
    if (siteMenu.hidden) {
      openMenu()
    } else {
      closeMenu()
    }
  })

  document.addEventListener("click", function (event) {
    if (siteMenu.hidden) return
    if (siteMenu.contains(event.target) || toggleButton.contains(event.target)) return

    closeMenu()
  })
})
