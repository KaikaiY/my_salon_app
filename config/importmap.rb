# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "header_menu", to: "header_menu.js"
pin "invitation_form", to: "invitation_form.js"
pin "invitation_copy", to: "invitation_copy.js"
