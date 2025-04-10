import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { url: String }
    timeout = null

    submit(event) {
        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => {
            const query = event.target.value
            fetch(`${this.urlValue}?query=${encodeURIComponent(query)}`, {
                headers: { Accept: "text/vnd.turbo-stream.html" }
            })
                .then(response => response.text())
                .then(html => Turbo.renderStreamMessage(html))
        }, 300)
    }
}