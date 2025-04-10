import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import FlashController from "./flash_controller"
application.register("flash", FlashController)

import SearchController from "./search_controller"
application.register("posts_list", SearchController)