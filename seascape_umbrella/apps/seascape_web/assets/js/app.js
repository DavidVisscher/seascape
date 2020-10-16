// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import Chart from "chart.js"
import NProgress from "nprogress"

import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

let Hooks = {};
Hooks.TimeLineChart = {
    mounted() {
        let self = this;
        this.label = this.el.dataset.label;
        this.points = JSON.parse(this.el.dataset.points);
        this.xs = this.el.dataset.xs;
        let options = {
            type: 'line',
            data: {
                datasets: [{
                    label: this.label,
                    data: this.points
                }]
            },
            options: {
                scales: {
                    xAxes: [{
                        type: 'time'
                    }]
                }
            }
        };
        let canvas = this.el.appendChild(document.createElement('canvas'));
        this.chart = new Chart(canvas, options);
    },
    updated() {
        // let data = JSON.parse(this.el.dataset.points);
        this.points = JSON.parse(this.el.dataset.points);
        this.chart.data.datasets[0].data = this.points;
        this.chart.update();
        console.log(this);
        console.log(this.chart.data);
        return true;
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})


// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())
// Connect if there are any LiveViews on the page
liveSocket.connect()

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
