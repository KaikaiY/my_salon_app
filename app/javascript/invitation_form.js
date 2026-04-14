document.addEventListener("turbo:load", function () {
  const roleSelect = document.getElementById("invitation-role")
  const companyField = document.getElementById("company-field")
  const companySelect = document.getElementById("invitation-company")

  if (!roleSelect || !companyField || !companySelect) return

  function toggleCompanyField() {
    const selectedRole = roleSelect.value

    if (selectedRole === "company_manager" || selectedRole === "employee") {
      companyField.style.display = "block"
    } else {
      companyField.style.display = "none"
      companySelect.value = ""
    }
  }

  roleSelect.addEventListener("change", toggleCompanyField)

  toggleCompanyField()
})