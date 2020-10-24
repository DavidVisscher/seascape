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

// A quick and dirty way to perform structural comparison between two non-cyclic objects.
function deepEqual(a, b) {
    return JSON.stringify(a) === JSON.stringify(b);
}

/// Build a Chart using Charts.js
/// Expects three data-attributes: `data-chart-data, data-chart-options, data-chart-type`
/// these correspond to the `data`, `options` and `type` fields that Chart.js uses, respectively.
/// (See documentation at https://www.chartjs.org/docs/latest/getting-started/)
///
/// LiveView can alter what data or options are used at any time,
/// and these changes will be propagated.
/// If only the info contained in the dataset(s) is altered, this will animate as 'new data'
/// being added to the existing graph, rather than replacing the whole graph.
Hooks.Chart = {
    refreshData() {
        let type = this.el.dataset.chartType || 'line';
        let data = JSON.parse(this.el.dataset.chartData) || {};
        let options = JSON.parse(this.el.dataset.chartOptions) || {};
        if(!deepEqual(this.chartType, type)) {
            this.chartType = type;
        }
        if(!deepEqual(this.chartOptions, options)) {
            this.chartOptions = options;
        }
        this.chartData = data;

        let result = {type: type, data: data, options: options};
        return result;
    },
    mounted() {
        let canvas = this.el.appendChild(document.createElement('canvas'));
        let settings = this.refreshData();
        this.chart = new Chart(canvas, settings);
    },
    updated() {
        let {type, data, options} = this.refreshData();
        this.chart.type = this.chartType;
        this.chart.options = this.chartOptions;
        for(var field in data){
            if(field == "datasets") {
                continue;
            }
            this.chart.data[field] = data[field];
        }
        for(let index = 0; index < data.datasets.length; ++index){
            this.chart.data.datasets[index] ||= {};
            this.chart.data.datasets[index].data = data.datasets[index].data;
        }
        // }
        this.chart.update();
    }
};


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
