.__ytb{
#yt-admin.vm-dashboard {
    background: transparent;
}

.dashboard_content {
    float: none;
    position: relative;
    background: #f6f6f6;
    margin-top: 5px;
    border: 1px solid #e2e2e2;
    -moz-border-radius-topleft: 5px;
    -webkit-border-top-left-radius: 5px;
    border-top-left-radius: 5px;
    -moz-border-radius-topright: 5px;
    -webkit-border-top-right-radius: 5px;
    border-top-right-radius: 5px;
}

#dashboard-no-videos-overlay {
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    z-index: 2;
    text-align: center;
    background: #e6e6e6;
    background: rgba(237,237,237,.85);
}

#dashboard-no-videos-message {
    width: 400px;
    margin: 130px auto;
}

#dashboard-no-videos-main,#dashboard-no-videos-subtext {
    margin: 30px 0;
}

#dashboard-no-videos-main {
    font-size: 25px;
    font-weight: bold;
}

#dashboard-no-videos-subtext {
    font-size: 13px;
    text-align: left;
}

#dashboard-no-videos-upload {
    padding: 0 40px;
}

#dashboard-header {
    padding: 16px 0px 6px 20px;
    margin: 0 0 4px 0;
}

#dashboard-header .yt-user-photo:hover {
    text-decoration: none;
}

#dashboard-header .yt-user-photo {
    float: left;
}

#dashboard-header-stats {
    float: right;
    margin-top: 8px;
}

#dashboard-header .dashboard-stat-value {
    font-size: 14px;
    font-weight: bold;
    color: #888;
    text-shadow: 0 1px 0 #fff;
    line-height: 1em;
    margin: 4px 0px 10px 0px;
}

#dashboard-header .dashboard-stat-name {
    font-size: 11px;
    color: #666;
    text-shadow: 0 1px 0 #fff;
    line-height: 1em;
}

#dashboard-header-stats li {
    font-size: 16px;
    color: #777;
    text-align: center;
    margin-right: 36px;
    display: inline-block;
    *display: inline;
    *zoom: 1;
}

#dashboard-header-user-name-and-label {
    float: left;
    margin-top: 8px;
    display: inline-block;
    *display: inline;
    *zoom: 1;
}

#dashboard-header h1 {
    margin: 0 0 0 20px;
    font-weight: bold;
    font-size: 24px;
    color: #555;
    text-shadow: 0 1px 0 #fff;
    line-height: 1em;
    margin-bottom: 8px;
}

#dashboard-header h2 {
    margin: 0 0 0 20px;
    font-size: 11px;
    color: #666;
    text-shadow: 0 1px 0 #fff;
    line-height: 1em;
}

.dashboard-header-right {
    float: right;
}

.add-widget-clickcard {
    margin-right: -14px;
    position: relative;
    top: -9px;
}

.add-widget-button {
    cursor: pointer;
}

.add-widget-button,.add-widget-menu-item-add {
    background: no-repeat url(http://s.ytimg.com/yt/imgbin/www-videomanager-vflsMc6Qh.png) 0 -765px;
    width: 20px;
    height: 20px;
}

.add-widget-button:hover,.add-widget-menu-content li div:hover .add-widget-menu-item-add {
    background: no-repeat url(http://s.ytimg.com/yt/imgbin/www-videomanager-vflsMc6Qh.png) 0 -439px;
    width: 20px;
    height: 20px;
}

.add-widget-menu-content h2 {
    font-size: 13px;
    font-weight: bold;
    padding-bottom: 8px;
    color: #666;
}

.add-widget-menu-content li {
    padding-top: 6px;
    border-top: 1px solid #ccc;
}

.add-widget-menu-item {
    height: 32px;
    color: #333;
    margin-bottom: 8px;
    padding-left: 10px;
    padding-right: 10px;
    cursor: pointer;
}

.add-widget-menu-item.added {
    cursor: default;
}

.add-widget-menu-item:hover {
    color: #fff;
    background-color: #aaa;
    -moz-border-radius: 3px;
    -webkit-border-radius: 3px;
    border-radius: 3px;
}

.add-widget-menu-item .add-widget-menu-item-add,.add-widget-menu-item .add-widget-menu-item-added {
    float: right;
}

.add-widget-menu-item-title {
    float: left;
    padding-top: 9px;
    font-weight: bold;
}

.add-widget-menu-item .add-widget-menu-item-added {
    padding-top: 9px;
    font-weight: bold;
    font-size: 11px;
}

.add-widget-menu-item .add-widget-menu-item-add {
    margin-top: 5px;
}

.add-widget-menu-item.added .add-widget-menu-item-add,.add-widget-menu-item .add-widget-menu-item-added {
    display: none;
}

.add-widget-menu-item.added .add-widget-menu-item-added {
    display: inline;
}

.dashboard-widget {
    background-color: #fff;
    color: #666;
    font-weight: normal;
    padding: 20px;
    position: relative;
    font-size: 11px;
    margin: 10px 20px;
    border: solid 1px #dcdcdc;
    opacity: 1;
    -moz-border-radius: 3px;
    -webkit-border-radius: 3px;
    border-radius: 3px;
    -moz-box-shadow: 0 1px 4px #c9c9c9;
    -ms-box-shadow: 0 1px 4px #c9c9c9;
    -webkit-box-shadow: 0 1px 4px #c9c9c9;
    box-shadow: 0 1px 4px #c9c9c9;
    -moz-transition: opacity 0.5s ease;
    -ms-transition: opacity 0.5s ease;
    -o-transition: opacity 0.5s ease;
    -webkit-transition: opacity 0.5s ease;
    transition: opacity 0.5s ease;
}

.dashboard-widget.invisible {
    opacity: 0;
    -moz-transition: opacity 0.5s ease;
    -ms-transition: opacity 0.5s ease;
    -o-transition: opacity 0.5s ease;
    -webkit-transition: opacity 0.5s ease;
    transition: opacity 0.5s ease;
}

.dashboard-widget.start-invisible {
    opacity: 0;
}

.dashboard-widgets-left,.dashboard-widgets-right {
    float: left;
    width: 50%;
}

.dashboard-widget {
    background-color: #fff;
    color: #666;
    font-weight: normal;
    padding: 20px 20px;
    position: relative;
    font-size: 11px;
    margin: 10px 20px;
    border: solid 1px #dcdcdc;
    -moz-border-radius: 3px;
    -webkit-border-radius: 3px;
    border-radius: 3px;
    -moz-box-shadow: 0px 1px 4px #c9c9c9;
    -ms-box-shadow: 0px 1px 4px #c9c9c9;
    -webkit-box-shadow: 0px 1px 4px #c9c9c9;
    box-shadow: 0px 1px 4px #c9c9c9;
}

.dashboard-widgets-left,.dashboard-widgets-right {
    float: left;
    width: 50%;
}

.dashboard-widgets-left .dashboard-widget {
    margin-right: 8px;
}

.dashboard-widgets-right .dashboard-widget {
    margin-left: 8px;
}

.dashboard-widget .yt-uix-button-link {
    text-transform: none;
}

.dashboard-widget-item+.dashboard-widget-item {
    margin-top: 24px;
}

.dashboard-widget h3 {
    font-size: 11px;
}

.dashboard-widget h2 {
    font-weight: bold;
    font-size: 13px;
    margin-bottom: 0;
    margin-top: 0;
    color: #666;
    overflow: hidden;
    white-space: nowrap;
    word-wrap: normal;
    *zoom: 1;
    -o-text-overflow: ellipsis;
    text-overflow: ellipsis;
}

.dashboard-widget-edit-title h4 {
    padding-top: 4px;
    padding-bottom: 4px;
}

.dashboard-widget.display .yt-uix-dragdrop-drag-handle {
    cursor: arrow;
}

.dashboard-widget .view-all-link {
    text-align: right;
    margin-top: 10px;
}

.dashboard-widget .view-all-link a {
    color: #666;
}

.dashboard-widget .content {
    -moz-transition: margin-left 0.5s;
    -ms-transition: margin-left 0.5s;
    -o-transition: margin-left 0.5s;
    -webkit-transition: margin-left 0.5s;
    transition: margin-left 0.5s;
    -moz-transition-timing-function: ease;
    -webkit-transition-timing-function: ease;
    -o-transition-timing-function: ease;
    -ms-transition-timing-function: ease;
    transition-timing-function: ease;
}

.dashboard-widget .content,.dashboard-widget .config {
    width: 312px;
    float: left;
}

.dashboard-widget.edit .content {
    margin-left: -312px;
}

.dashboard-widget.edit .dashboard-widget-display-title {
    display: none;
}

.dashboard-widget.display .dashboard-widget-edit-title {
    display: none;
}

.dashboard-widget-header {
    display: block;
    margin: -20px -20px 13px -20px;
    height: 45px;
    padding: 0 18px;
}

.dashboard-widget-viewport {
    width: 312px;
    overflow: hidden;
}

.dashboard-widget-inside {
    width: 624px;
}

.dashboard-widget-header:hover,.dashboard-widget.edit .dashboard-widget-header,.dashboard-widget.yt-uix-dragdrop-dragged-item .dashboard-widget-header,.dashboard-widget.yt-uix-dragdrop-cursor-follower .dashboard-widget-header {
    background-color: #fbfbfb;
}

.dashboard-widget-header-controls {
    float: right;
    visibility: hidden;
}

.dashboard-widget:hover .dashboard-widget-header .dashboard-widget-header-controls,.dashboard-widget.yt-uix-dragdrop-dragged-item .dashboard-widget-header .dashboard-widget-header-controls,.dashboard-widget.yt-uix-dragdrop-cursor-follower .dashboard-widget-header .dashboard-widget-header-controls {
    visibility: visible;
}

.dashboard-widget-header h2 {
    padding-top: 14px;
}

.field-with-error,.field-with-error:focus {
    border: 3px solid #c00;
}

.dashboard-widget.yt-uix-dragdrop-dragged-item {
    visibility: visible;
    border: 1px dotted #000;
    opacity: 0.3;
}

.dashboard-widget-config-button {
    cursor: pointer;
    margin-left: 6px;
    margin-top: 15px;
    filter: alpha(opacity=40);
    opacity: 0.4;
    background: no-repeat url(http://s.ytimg.com/yt/imgbin/www-videomanager-vflsMc6Qh.png) 0 -577px;
    width: 15px;
    height: 15px;
}

.dashboard-widget-config-button:hover {
    filter: alpha(opacity=100);
    opacity: 1;
}

.dashboard-widget-handle {
    margin-top: 15px;
    margin-right: 6px;
    background: no-repeat url(http://s.ytimg.com/yt/imgbin/www-videomanager-vflsMc6Qh.png) 0 -670px;
    width: 17px;
    height: 14px;
}

.dashboard-widget-custom-title {
    padding-top: 4px;
    padding-bottom: 3px;
    height: 16px;
    margin-top: 11px;
}

.dashboard-widget .config-controls {
    clear: both;
    margin-top: 15px;
    padding-top: 15px;
    border-top: 1px solid #ddd;
    height: 32px;
}

.dashboard-widget .config-controls .config-controls-left {
    float: left;
}

.dashboard-widget .config-controls .config-controls-right {
    float: right;
}

#dashboard-welcome-header {
    background: #59aafc;
    color: #fff;
    margin: 0 -20px 15px -20px;
    padding: 25px;
    text-shadow: 0 -1px 1px rgba(0,0,0,.1);
    -moz-border-radius: 5px 5px 0 0;
    -webkit-border-radius: 5px 5px 0 0;
    border-radius: 5px 5px 0 0;
}

#dashboard-welcome-header h2 {
    border: none;
    color: #fff;
    margin: 5px;
    font-size: 32px;
    font-weight: normal;
    text-align: center;
}

#dashboard-welcome-header .dashboard-explanation {
    font-size: 14px;
    margin: 0 auto;
    width: 500px;
}

#dashboard-welcome-dialog .yt-dialog-fg {
    width: 750px;
}

#dashboard-welcome-dialog img {
    display: block;
    margin: 0 auto;
}

#dashboard-welcome-dialog .yt-dialog-footer {
    text-align: center;
}

.dashboard-dialog-screenshot-text {
    display: none;
}

.dashboard-widget.analytics a:hover {
    text-decoration: none;
}

.dashboard-widget.analytics .section {
    padding-top: 5px;
}

.dashboard-widget.analytics .section+.section {
    margin-top: 25px;
    padding-top: 25px;
    border-top: 1px solid #ddd;
}

.dashboard-widget.analytics .section-sparkline {
    float: right;
}

.dashboard-widget.analytics .section-sparkline img {
    float: left;
}

.dashboard-widget.analytics .section-value {
    color: #5f8fc9;
    font-size: 24px;
    font-weight: bold;
}

.dashboard-widget.analytics .section-label {
    padding-top: 10px;
    color: #777;
    font-size: 10px;
}

.dashboard-widget.comments .no-comments {
    height: 255px;
    color: #999;
    font-size: 13px;
    font-weight: bold;
    text-align: center;
    white-space: normal;
}

.dashboard-widget.comments .no-comments .yt-valign-container {
    width: 200px;
}

.dashboard-widget.comments .comment-thumb {
    float: left;
}

.dashboard-widget.comments .comment-body {
    margin-left: 28px;
    padding-left: 10px;
}

.dashboard-widget.comments .quotation-mark {
    margin-right: 5px;
    display: inline-block;
    vertical-align: middle;
    height: 10px;
    width: 10px;
    background: no-repeat url(http://s.ytimg.com/yt/imgbin/www-videomanager-vflsMc6Qh.png) 0 -513px;
}

.dashboard-widget.comments .comment-comment {
    line-height: 1.3em;
    max-height: 2.6em;
    overflow: hidden;
    margin-bottom: 5px;
}

.dashboard-widget.comments .comment-comment a {
    color: #666;
}

.dashboard-widget.comments .comment-list-item-links li {
    display: inline-block;
    *display: inline;
    *zoom: 1;
    *border-left: 1px solid #999;
    *padding: 0 6px;
}

.dashboard-widget.comments .comment-list-item-links li+li:before {
    content: '\002022';
    margin: 0 2px;
}

.dashboard-widget.comments .comment-list-item-links li:first-child {
    *border-left: none;
    *padding-left: 0;
}

.dashboard-widget.comments .selectable-item .vm-link {
    display: none;
}

.dashboard-widget.comments .selectable-item:hover .vm-link {
    display: inline-block;
}

.dashboard-widget.comments .view-all-link {
    font-weight: bold;
}

.yt-rounded {
    -moz-border-radius: 2px;
    -webkit-border-radius: 2px;
    border-radius: 2px;
}

.yt-rounded-top {
    -moz-border-radius-topleft: 2px;
    -webkit-border-top-left-radius: 2px;
    border-top-left-radius: 2px;
    -moz-border-radius-topright: 2px;
    -webkit-border-top-right-radius: 2px;
    border-top-right-radius: 2px;
}

.yt-rounded-bottom {
    -moz-border-radius-bottomleft: 2px;
    -webkit-border-bottom-left-radius: 2px;
    border-bottom-left-radius: 2px;
    -moz-border-radius-bottomright: 2px;
    -webkit-border-bottom-right-radius: 2px;
    border-bottom-right-radius: 2px;
}

.dashboard-widget.notification .yt-alert-naked {
    vertical-align: middle;
    margin: 0;
    display: inline-block;
    *display: inline;
    *zoom: 1;
}

.dashboard-widget.notification .notification-dismiss {
    color: #aaa;
    padding: 2px;
    height: 20px;
    width: 20px;
    position: absolute;
    top: 10px;
    right: 10px;
    text-align: center;
}

.dashboard-widget.notification .notification-dismiss:hover {
    background-color: #aaa;
    color: white;
}

.dashboard-widget.notification .notification-dismiss:hover .yt-uix-button-content {
    text-decoration: none;
}

.dashboard-widget.notification .notification-action {
    margin-top: 10px;
    text-align: center;
    width: 100%;
}

.dashboard-widget.notification .notification-action .yt-uix-button {
    display: block;
}

.dashboard-widget.notification .notification-action button {
    width: 100%;
}

.dashboard-widget.promos {
    margin-bottom: 10px;
}

.dashboard-widget.promos .promos-content-container {
    background: #f4f4f4;
    border-color: #f1f1f1;
    -moz-border-radius: 2px;
    -webkit-border-radius: 2px;
    border-radius: 2px;
    margin: auto;
    width: 244px;
}

.dashboard-widget.promos .yt-uix-slider-item {
    width: 218px;
    padding: 15px 12px;
}

.dashboard-widget.promos .yt-uix-slider-next.yt-uix-button-default,.dashboard-widget.promos .yt-uix-slider-prev.yt-uix-button-default,.dashboard-widget.promos .yt-uix-slider .yt-uix-button-default[disabled] {
    margin-top: 0;
    background-image: none;
    background: #f4f4f4;
    border-color: #f1f1f1;
    position: absolute;
    height: 100%;
    opacity: .5;
    filter: alpha(opacity=50);
    -moz-border-radius: 2px;
    -webkit-border-radius: 2px;
    border-radius: 2px;
}

.dashboard-widget.promos .yt-uix-slider-prev.yt-uix-button-default {
    top: 0;
    left: 0;
}

.dashboard-widget.promos .yt-uix-slider-next.yt-uix-button-default {
    top: 0;
    right: 0;
}

.dashboard-widget.promos .promos-slider-container {
    position: relative;
}

.dashboard-widget.promos .yt-uix-slider-slide {
    padding: 0 3px;
}

.dashboard-widget.promos .yt-uix-slider-next:hover,.dashboard-widget.promos .yt-uix-slider-prev:hover {
    background: #e9e9e9;
}

.dashboard-widget.promos .yt-uix-slider-prev-arrow,.dashboard-widget.promos .yt-uix-slider-next-arrow {
    border: none;
    height: 12px;
    width: 8px;
}

.dashboard-widget.promos .yt-uix-slider-prev-arrow {
    background: no-repeat url(http://s.ytimg.com/yt/imgbin/www-videomanager-vflsMc6Qh.png) -14px -550px;
}

.dashboard-widget.promos .yt-uix-slider-next-arrow {
    background: no-repeat url(http://s.ytimg.com/yt/imgbin/www-videomanager-vflsMc6Qh.png) -16px 0;
}

.dashboard-widget.promos .promo-image {
    display: block;
    margin: 4px 0;
    -moz-box-shadow: 0 1px 1px #ccc;
    -ms-box-shadow: 0 1px 1px #ccc;
    -webkit-box-shadow: 0 1px 1px #ccc;
    box-shadow: 0 1px 1px #ccc;
}

.dashboard-widget.promos h3 {
    font-weight: bold;
    font-size: 13px;
    margin-bottom: 0;
    margin-top: 0;
    color: #666;
}

.dashboard-widget.promos .yt-uix-pager {
    float: none;
    margin: 0;
    text-align: center;
}

.dashboard-widget.promos .yt-uix-pager .yt-uix-slider-num {
    height: auto;
    margin: 10px 2px 0 3px;
    line-height: 10px;
    padding: 0;
    background: none;
    filter: none;
    border: none;
    font-size: 28px;
    color: #c0c0c0;
}

.dashboard-widget.promos .yt-uix-pager .yt-uix-slider-num-current,.dashboard-widget.promos .yt-uix-pager .yt-uix-slider-num:hover {
    color: #797979;
    border: none;
    -moz-box-shadow: none;
    -ms-box-shadow: none;
    -webkit-box-shadow: none;
    box-shadow: none;
}

.dashboard-widget.videos .video-date-added,.dashboard-widget.videos .viewcount {
    color: #999;
}

.dashboard-widget.videos h3 {
    font-weight: normal;
}

.dashboard-widget.videos .video-list-item h3 {
    margin-top: 0;
}

.dashboard-widget.videos .video-list-item .vm-thumb,.dashboard-widget.videos .video-list-item-info {
    float: left;
    max-width: 240px;
}

.dashboard-widget.videos .video-list-item-info {
    width: 100%;
}

.dashboard-widget.videos .video-list-item-details li {
    display: inline-block;
    *display: inline;
    *zoom: 1;
    *border-left: 1px solid #999;
    *padding: 0 6px;
}

.dashboard-widget.videos .video-list-item-details li+li:before {
    content: '\002022';
    margin: 0 2px;
}

.dashboard-widget.videos .video-list-item-details li:first-child {
    *border-left: none;
    *padding-left: 0;
}

.dashboard-widget.videos a:hover {
    color: #006cd8;
    text-decoration: underline;
}

.dashboard-widget.videos .video-title a {
    color: #666;
    font-weight: bold;
}

.dashboard-widget.videos .video-edit-button a {
    color: #1c62b9;
}

.dashboard-widget.videos .video-list-item a {
    display: inline;
    padding: 0;
}

.dashboard-widget.videos .title {
    font-size: 12px;
    font-weight: normal;
}

.dashboard-widget.videos .video-title {
    line-height: 1.3em;
    max-height: 2.6em;
    overflow: hidden;
}

.dashboard-widget.videos .video-list-item .video-edit-button {
    display: none;
}

.dashboard-widget.videos .video-list-item:hover .video-edit-button {
    display: inline;
}

.dashboard-widget.videos .video-list-item .video-edit-button a.yt-uix-button {
    padding: 2px 10px;
    height: 20px;
    line-height: normal;
}

.dashboard-widget.videos .video-time,.dashboard-widget.videos .addto-watch-later-button {
    display: none;
}

.dashboard-widget.videos .video-thumb.yt-thumb-default-64,.dashboard-widget.videos .video-thumb.yt-thumb-default-64 img {
    width: 64px;
}

.dashboard-widget.videos .video-thumb.yt-thumb-default-64 {
    height: 36px;
}

.yt-uix-dragdrop-cursor-follower {
    position: absolute;
    pointer-events: none;
}

.yt-uix-dragdrop-no-pointer-events {
    margin-top: 5px;
    margin-left: 5px;
}

.yt-uix-dragdrop-container {
    min-height: 20px;
}

.yt-uix-dragdrop-dragged-item {
    visibility: hidden;
}

.yt-uix-dragdrop-drag-handle,.yt-uix-dragdrop-cursor-follower,.yt-uix-dragdrop-show-move-cursor {
    cursor: move;
}
}