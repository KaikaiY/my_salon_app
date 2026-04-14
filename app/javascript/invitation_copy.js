document.addEventListener("turbo:load", function () {
  const invitationCopyButtons = document.getElementsByClassName("copy-invitation-url")

  for (const button of invitationCopyButtons) {
    button.addEventListener("click", function () {
      const buttonUrl = button.dataset.url
      navigator.clipboard.writeText(buttonUrl)
    })
  }
})
