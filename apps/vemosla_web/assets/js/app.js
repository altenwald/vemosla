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
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"
import '@fortawesome/fontawesome-free/js/all'
import "selectize/dist/js/selectize.min.js"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

if (window.userToken) {
  let socket = new Socket("/socket", {params: {token: window.userToken}})
  socket.connect()

  let channel = socket.channel("topic:search", {})
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp)})
    .receive("error", resp => { console.log("Unable to join", resp) })

  var delaySearch;

  $(function() {

    $('#post_movie_id').selectize({
      valueField: 'id',
      labelField: 'title',
      searchField: 'title',
      options: [],
      create: false,
      render: {
        option: function(item, escape) {
          return '<div class="search-movie">' +
            '<img src="' + escape(item.poster_url) + '" alt=""/>' +
            '<span class="title">' +
              '<span class="name">' + escape(item.title) + '</span>' +
              '<span class="overview">' + escape(item.overview) + '</span>' +
            '</span>' +
          '</div>'
        }
      },
      load: function(query, callback) {
        if (!query.length) return callback()
        clearTimeout(delaySearch)
        delaySearch = setTimeout(function() {
          channel.push("search", query)
            .receive("ok", resp => callback(resp))
            .receive("error", resp => console.log(error))
        }, 1500)
      }
    })

    $("section.post").each(function(i, s) {
      var key = "section." + $(s).attr('class').replace(" ", ".") + ":after"
      var value = "background-image: url('" + $(s).attr('background-url') + "');"
      console.log("key", key)
      console.log("value", value)
      document.styleSheets[0].addRule(key, value)
    })

    $("#post_reactions_0_watched").on("change", function(event){
      let checked = $("#post_reactions_0_watched").prop("checked")
      if (checked) {
        $("#post_reactions_0_reaction_watched").removeClass("is-hidden")
        $("#post_reactions_0_reaction_non_watched").addClass("is-hidden")
      } else {
        $("#post_reactions_0_reaction_watched").addClass("is-hidden")
        $("#post_reactions_0_reaction_non_watched").removeClass("is-hidden")
      }
    })

  })
}

$(function(){
  $(".navbar-burger").on('click', function(event) {
    $(".navbar-burger").toggleClass("is-active")
    $(".navbar-menu").toggleClass("is-active")
  })
})
