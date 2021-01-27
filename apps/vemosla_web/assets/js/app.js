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

if (window.userToken && document.location.pathname == "/posts/new") {
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

function create_comment(comment) {
  let avatar =
    $(document.createElement('img'))
      .attr('src', comment.photo)
  let image_div =
    $(document.createElement('div'))
      .addClass(["column", "is-2", "is-hidden-mobile"])
      .append(avatar)

  let metadata =
    $(document.createElement('span'))
      .addClass("post-description-metainfo")
      .append(comment.inserted_at)
  let content =
    $(document.createElement('span'))
      .addClass("post-description-content")
      .append(comment.comment)
  let user =
    $(document.createElement('a'))
      .addClass("post-description-author")
      .attr("href", comment.user_profile_url)
      .append(comment.user_name)
  let comment_div =
    $(document.createElement('div'))
      .addClass(["column", "is-10"])
      .append(user)
      .append(" ")
      .append(content)
      .append(metadata)

  let columns =
    $(document.createElement('div'))
      .addClass('columns')
      .append(image_div)
      .append(comment_div)

  $("#post-comments-" + comment.post_id).append(columns)
  update_scroll("#post-comments-" + comment.post_id)
}

function update_reactions(payload) {
  let post_id = payload.post_id
  let reactions = payload.reactions
  $("span.badge.reaction-badge[data-post_id='" + post_id + "']").remove()
  for (const idx in reactions) {
    let reaction = reactions[idx]
    if (reaction.count == 0) continue
    let id =
      (reaction.watched ? "watched" : "non_watched") + "-" +
      reaction.reaction + "-" +
      post_id

    let badge =
      $(document.createElement('span'))
        .addClass(['badge', 'reaction-badge'])
        .attr("data-post_id", post_id)
        .attr('id', 'badge-' + id)
        .append(reaction.count)
    $("#reaction-" + id).append(badge)
  }
}

if (window.userToken && document.location.pathname == "/timeline") {
  let socket = new Socket("/socket", {params: {token: window.userToken}})
  socket.connect()

  var post_ids = []
  $("section.post").each((i, item) => {
    let post_id = $(item).data("post_id")
    post_ids.push(post_id)
  })
  let reactions = socket.channel("topic:reactions", {post_ids})
  let comments = socket.channel("topic:comments", {post_ids})
  reactions.join()
    .receive("ok", resp => { console.log("Joined successfully", resp)})
    .receive("error", resp => { console.log("Unable to join", resp) })
  comments.join()
    .receive("ok", resp => { console.log("Joined successfully", resp)})
    .receive("error", resp => { console.log("Unable to join", resp) })

  reactions.on("update_reactions", reactions => { update_reactions(reactions) })
  comments.on("comment", comment => { create_comment(comment) })

  $(function(){
    $(".reaction-button").on("click", function(event){
      event.preventDefault()
      let post_id = $(this).data("post")
      let watched = $(this).data("watched")
      let reaction = $(this).data("reaction")
      reactions.push("reaction", {post_id, watched, reaction})
        .receive("ok", resp => { console.log(resp) })
        .receive("error", resp => { console.log(resp) })
    })

    $(".send-button").on("click", function(event){
      event.preventDefault()
      send_comment($(this).data("post_id"))
    })

    $(".comment-input").on("keypress", function(event){
      if (event.key == "Enter") {
        event.preventDefault();
        send_comment($(this).data("post_id"))
      }
    })
  })
  
  function send_comment(post_id) {
    let text = $("#comment-" + post_id).val()
    comments.push("comment", {post_id, text})
      .receive("ok", resp => {
        $("#comment-" + post_id)
          .val("")
          .removeClass("is-danger")
          .trigger("focus")
      })
      .receive("error", resp => {
        $("#comment-" + post_id)
          .addClass("is-danger")
          .trigger("focus")
      })
  }
}

function update_scroll(id) {
  $(id).scrollTop($(id).prop("scrollHeight"))
}

window.update_scroll = update_scroll

$(function(){
  $(".navbar-burger").on('click', function(event) {
    $(".navbar-burger").toggleClass("is-active")
    $(".navbar-menu").toggleClass("is-active")
  })

  $(".post-comments").each(function(i, item){
    update_scroll(item)
  })

  $("section.post").each(function(i, s) {
    var key = "section." + $(s).attr('class').replace(" ", ".") + ":after"
    var value = "background-image: url('" + $(s).attr('background-url') + "');"
    console.log("key", key)
    console.log("value", value)
    document.styleSheets[0].addRule(key, value)
  })
})
