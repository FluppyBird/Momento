import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.textContent = "Hello World!"
    console.log("✅ hello_controller 已加载并连接")
  }
}
