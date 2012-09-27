(function () {
    setTimeout(function () {function q(a) {
            return null == document.cookie.match(RegExp("(^" + a + "| " + a + ")=([^;]*)")) ? "" : RegExp.$2
        }function m(a) {
            var b = "";
            try {
                b = decodeURIComponent(decodeURIComponent(a))
            } catch (c) {
                try {
                    b = decodeURIComponent(a)
                } catch (d) {
                    b = a
                }
            }
            return b
        }function s(a) {
            this.fullUrl = a;
            this.noCacheIE = "&noCacheIE=" + (new Date).getTime();
            this.headLoc = document.getElementsByTagName("head").item(0);
            this.scriptId = "JscriptId" + s.scriptCounter++
        }function o(a, b, c) {
            b && (window[b] = c);
            a = -1 != a.indexOf("?") ? a + ("&jsonp=" + b) : a + ("?jsonp=" + b);
            b = new s(a);
            b.buildScriptTag();
            b.addScriptTag()
        }function H(a, b, c) {
            b && (window[b] = c);
            a = new s(a + ("&callback=" + b));
            a.buildScriptTag();
            a.addScriptTag();
            return this
        }function w(a, b, c, d) {
            if (2 < arguments.length) {
                var e = new Date((new Date).getTime() + 36E5 * c);
                document.cookie = a + "=" + encodeURIComponent(b) + "; path=/; domain=xunlei.com; expires=" + e.toGMTString()
            } else document.cookie = a + "=" + encodeURIComponent(b) + "; path=/; domain=xunlei.com"
        }
        var r = 0 < window.navigator.userAgent.toLowerCase().indexOf("ipad") || 0 < window.navigator.userAgent.toLowerCase().indexOf("iphone") ? 1 : 0,
            x = -1 != navigator.appVersion.indexOf("MSIE") ? !0 : !1;
        navigator.userAgent.toUpperCase().indexOf("Firefox");
        var D = (new Date).getTime(),
            k = document.getElementById("XL_CLOUD_VOD_PLAYER");
        if (!k) return !1;
        s.scriptCounter = 1;
        s.prototype.buildScriptTag = function () {
            this.scriptObj = document.createElement("script");
            this.scriptObj.setAttribute("type", "text/javascript");
            this.scriptObj.setAttribute("src", this.fullUrl)
        };
        s.prototype.removeScriptTag = function () {
            this.headLoc.removeChild(this.scriptObj)
        };
        s.prototype.addScriptTag = function () {
            this.headLoc.appendChild(this.scriptObj)
        };
        var y = k.getAttribute("from"),
            y = y || "unkonwn",
            f = k.getElementsByTagName("a");
        if (0 != f.length) {
            var f = f[0],
                j = f.getAttribute("href"),
                I = f.getAttribute("filesize"),
                J = f.getAttribute("gcid"),
                E = f.getAttribute("cid"),
                B = f.getAttribute("title"),
                K = f.getAttribute("onsuccess"),
                M = f.getAttribute("playother"),
                N = f.getAttribute("onfail");
            k.style.height || (k.style.height = "446px");
            k.style.width || (k.style.width = "684px");
            k.style.overflow = "hidden";
            var j = j.replace(/(^\s*)|(\s*$)/g, ""),
                p = "url",
                z = f.getAttribute("share_url"),
                z = z ? z : m(j);
            if ("bt://" == m(j).substr(0, 5)) {
                var p = "bt",
                    u = m(j).substring(5, m(j).lastIndexOf("/"));
                40 != u.length && (u = "none");
                var L = "http://bt.box.n0808.com/" + u.substr(0, 2) + "/" + u.substr(38, 40) + "/" + u + ".torrent",
                    z = L
            }
            var A = f.getAttribute("autoplay"),
                A = !A || "true" != A ? !1 : !0,
                l = {
                    enableShare: !0,
                    enableFileList: !0,
                    enableDownload: !0,
                    enableSet: !0,
                    enableCaption: !0,
                    enableOpenWindow: !0
                },
                n = f.getAttribute("enable_panel");
            n && "false" == n && (l.enableShare = !1);
            if ((n = f.getAttribute("enable_download")) && "false" == n) l.enableDownload = !1;
            if ((n = f.getAttribute("enable_caption")) && "false" == n) l.enableCaption = !1;
            if ((n = f.getAttribute("enable_filelist")) && "false" == n) l.enableFileList = !1;
            if ((n = f.getAttribute("enable_setting")) && "false" == n) l.enableSet = !1;
            if ((n = f.getAttribute("enable_openwindow")) && "false" == n) l.enableOpenWindow = !1;
            var C = f.getAttribute("enable_kkva"),
                C = C && "true" == C ? !0 : !1,
                F = parseInt(f.getAttribute("start")) || 0,
                t = f.getAttribute("format") || "p",
                G = !1,
                O = /xyz/.test(function () {
                    xyz
                }) ? /\b_super\b/ : /.*/,
                f = function () {};
            f.extend = function (a) {function b() {
                    !G && this.init && this.init.apply(this, arguments)
                }
                var c = this.prototype;
                G = true;
                var d = new this;
                G = false;
                for (var e in a) d[e] = typeof a[e] == "function" && typeof c[e] == "function" && O.test(a[e]) ? function (a, b) {
                    return function () {
                        var d = this._super;
                        this._super = c[a];
                        var e = b.apply(this, arguments);
                        this._super = d;
                        return e
                    }
                }(e, a[e]) : a[e];
                b.prototype = d;
                b.constructor = b;
                b.extend = arguments.callee;
                return b
            };
            var v;
            window.XL_CLOUD_FX_INSTANCE = {
                Class: f,
                lastFormat: "p",
                lastDlUrl: "",
                cacheData: [],
                curPlay: null,
                curName: m(B),
                originalPlay: null,
                fileList: null,
                captionList: [],
                curUrl: j,
                user: {
                    u: "",
                    v: 0,
                    s: ""
                },
                init: function (a) {
                    v = a;
                    var b = this;
                    if (!b.validUrl(j)) {
                        b.error("您的点播url非法，无法播放！");
                        return false
                    }(a = k.getAttribute("id")) || k.setAttribute("id", "XL_CLOUD_PLAY_BOX");
                    k.style.backgroundColor = "#000";
                    try {
                        b.isThunderBox = window.external.IsInXLpanClient()
                    } catch (c) {
                        b.isThunderBox = false
                    }
                    b.isXlpan = /.*(xlpan).*/.exec(document.location.host);
                    b.uCheck();
                    var d = ["61.147.76.6", "61.147.76.6", "222.141.53.5", "222.141.53.5"];
                    goip = d[0];
                    o("http://dynamic.vod.lixian.xunlei.com/interface/getip?t=" + (new Date).getTime(), "XL_CLOUD_FX_INSTANCEqueryIpBack", function (a) {
                        try {
                            goip = d[a]
                        } catch (b) {
                            try {
                                goip = d[a.result]
                            } catch (c) {
                                goip = d[0]
                            }
                        }
                    });
                    window.onunload = function () {
                        b.reportPlayPos();
                        if (b.curPlay) {
                            try {
                                var a = G_PLAYER_INSTANCE.getTimePlayed(),
                                    c = a.playedtime,
                                    d = a.playedbyte,
                                    f = a.downloadbyte
                            } catch (g) {
                                f = d = c = 0
                            }
                            try {
                                var m = G_PLAYER_INSTANCE.getPlayPosition()
                            } catch (k) {
                                m = 0
                            }
                            var a = (a = b.curPlay.src_info) ? a.gcid || "" : "",
                                l = b.$PU("g", b.lastDlUrl) || "",
                                j = b.curPlay.duration / 1E6 || 0;
                            (new Image).src = "http://i.vod.xunlei.com/stat/s.gif?f=playtime&p=XCVP&totaltime=" + j + "&du=" + c + "&by=" + d + "&downby=" + f + "&t=" + m + "&gcid=" + l + "&ygcid=" + a + "&u=" + b.user.u + "&v=" + b.user.v + "&from=" + y + "&d=" + D
                        }
                        b.close()
                    };
                    setTimeout(function () {
                        b.stat({
                            p: "XCVP",
                            f: "pv"
                        })
                    }, 25)
                },
                uVipinfo: function () {
                    H("http://dynamic.vod.lixian.xunlei.com/interface/getuservipinfo?t=" + D, "XL_CLOUD_FX_INSTANCEqueryVipinfoBack", function (a) {
                        if (a.result == "0" && a.vipinfo.vip_payid) {
                            var b = a.vipinfo;
                            if (b.vip_payid - 1E3 > 0) {
                                var c = b.vip_expiredate.split("-"),
                                    d = a.svrtime.split("-"),
                                    a = c[0] - d[0],
                                    b = c[1] - d[1],
                                    c = c[2] - d[2],
                                    d = "";
                                if (c < 0) {
                                    var e = new Date,
                                        e = new Date(e.getFullYear(), e.getMonth() + 3, 0);
                                    if (b > 0) b = b - 1;
                                    else {
                                        a = a - 1;
                                        b = 11
                                    }
                                    c = e.getDate() + c
                                }
                                a > 0 && (d = d + (a + "年"));
                                b > 0 && (d = d + (b + "月"));
                                if (c > 8 || a > 0 || b > 0) return false;
                                G_PLAYER_INSTANCE.setNoticeMsg("您的体验会员将在" + (d + (c + "天")) + "后到期，建议您开通正式会员", 1500)
                            }
                        }
                    })
                },
                uCheck: function () {
                    var a = this;
                    if (a.isXlpan || a.isThunderBox) {
                        l.enableOpenWindow = false;
                        a.user.u = q("userid");
                        a.user.v = q("isvip");
                        a.user.s = q("sessionid");
                        a.query(j, B, J, E, I);
                        return true
                    }
                    var b = null;
                    isTimeout = true;
/*c begin*/
(function (){
  c = window.curUzreInfo;
  if (c && c.sessionid && c.isvip && c.userid) {
      a.user.u = c.userid;
      a.user.v = c.isvip;
      a.user.s = c.sessionid;
      if (!q("userid") && !q("isvip") && !q("sessionid")) {
          w("userid");
          w("isvip");
          w("sessionid")
      }
      a.query(j, B, J, E, I)
  } else a.error("您不是会员，请用会员帐号<a style='color:#1874CA;' href='javascript:;' onclick='XL_CLOUD_FX_INSTANCE.loginNotice();return false;'>登录</a>后回来继续");
  isTimeout = false;
  clearTimeout(b)
})()
/*c over*/
                    // o("/ajax/getXlCookie", function (c) {
                    // });

                    b = setTimeout(function () {
                        isTimeout && a.error("暂时无法验证您的登录状态，请稍后<a style='color:#1874CA;' href='javascript:;' onclick='XL_CLOUD_FX_INSTANCE.uCheck();return false;'>重试</a>");
                        isTimeout = false;
                        clearTimeout(b)
                    }, 3E4)
                },
                uUpdate: function () {
                    var a = this;
                    alert('todo');
                    // o("./getXlCookie.php?t=" + (new Date).getTime(), "XL_CLOUD_FX_INSTANCEqueryXlCookieBack", function (b) {
                    //     if (b && b.sessionid && b.isvip && b.userid) {
                    //         a.user.u = b.userid;
                    //         a.user.v = b.isvip;
                    //         a.user.s = b.sessionid;
                    //         if (!q("userid") && !q("isvip") && !q("sessionid")) {
                    //             w("userid");
                    //             w("isvip");
                    //             w("sessionid")
                    //         }
                    //     }
                    // })
                },
                reportPlayPos: function () {
                    return false;
                    if (this.curPlay && this.curPlay.ret == 0 && (this.user.v || q("isvip"))) {
                        var a = "";
                        if (p == "bt" && this.fileList && this.fileList.main_task_url_hash) a = this.fileList.main_task_url_hash;
                        else if (this.curPlay && this.curPlay.url_hash) a = this.curPlay.url_hash;
                        else return false;
                        try {
                            var b = G_PLAYER_INSTANCE.getPlayPosition(),
                                b = Math.ceil(b);
                            if (!b || b < 0) b = 0;
                            a = a + "_" + b
                        } catch (c) {
                            return false
                        }
                        b = 0;
                        if (p == "bt") {
                            a = a + "_1";
                            b = this.curUrl.substr(parseInt(this.curUrl.lastIndexOf("/")) + 1, this.curUrl.length)
                        } else a = a + "_0";
                        try {
                            o("http://i.vod.xunlei.com/req_report_play_pos?userid=" + this.user.u + "&report_data=" + a + "_" + b + "&t=" + (new Date).getTime(), "XL_CLOUD_FX_INSTANCEreportPosBack", function () {
                                return false
                            })
                        } catch (d) {}
                    }
                },
                initEvent: function () {
                    var a = this;
                    G_PLAYER_INSTANCE.attachEvent(G_PLAYER_INSTANCE, "onGetFormats", function () {});
                    G_PLAYER_INSTANCE.attachEvent(G_PLAYER_INSTANCE, "onSetFormats", function (b, c, d, e, i, h) {
                        a.setFormats(d, e, i, h)
                    });
                    G_PLAYER_INSTANCE.attachEvent(G_PLAYER_INSTANCE, "onErrorStat", function (b, c, d) {
                        a.stat({
                            f: "playerror",
                            e: d
                        });
                        if (a.kkvaUsed) {
                            try {
                                G_PLAYER_INSTANCE.close();
                                G_PLAYER_INSTANCE.closeNetStream();
                                G_PLAYER_INSTANCE.setNoticeMsg("迅雷播放加速服务已经退出，您将无法继续观看视频,请刷新页面重试", 5E3)
                            } catch (e) {}
                            a.kkvaUsed = false
                        }
                    });
                    G_PLAYER_INSTANCE.attachEvent(G_PLAYER_INSTANCE, "onErrorExit", function (b, c, d) {
                        a.stat({
                            f: "playerror",
                            e: d,
                            gcid: a.$PU("g", a.lastDlUrl)
                        })
                    });
                    G_PLAYER_INSTANCE.attachEvent(G_PLAYER_INSTANCE, "onplaying", function () {
                        if (a.kkvaValid) {
                            a.kkvaUsed = true;
                            try {
                                G_PLAYER_INSTANCE.setNoticeMsg("<a href=\"javascript:XL_CLOUD_FX_INSTANCE.windowOpenInPlayer('http://dl.xunlei.com/xmp.html')\">迅雷播放加速服务中...</a>", 30)
                            } catch (b) {}
                            a.kkvaValid = false
                        }
                        a.stats_buff()
                    });
                    G_PLAYER_INSTANCE.attachEvent(G_PLAYER_INSTANCE, "onShowBufferTip", function () {
                        a.stat({
                            f: "buffer",
                            e: -2,
                            t: G_PLAYER_INSTANCE.getPlayPosition(),
                            gcid: a.$PU("g", a.lastDlUrl)
                        })
                    });
                    G_PLAYER_INSTANCE.attachEvent(G_PLAYER_INSTANCE, "onbuffering", function () {
                        a.stat({
                            f: "buffer",
                            e: -3,
                            t: G_PLAYER_INSTANCE.getPlayPosition(),
                            gcid: a.$PU("g", a.lastDlUrl)
                        })
                    });
                    G_PLAYER_INSTANCE.attachEvent(G_PLAYER_INSTANCE, "onSeek", function () {
                        a.stat({
                            f: "drag",
                            t: G_PLAYER_INSTANCE.getPlayPosition(),
                            gcid: a.$PU("g", a.lastDlUrl)
                        })
                    })
                },
                initPlayerEvent: function () {
                    if (r) return true;
                    var a = this;
                    G_PLAYER_INIT.attachEvent(G_PLAYER_INIT, "onLoadFlashError", function () {
                        a.error("播放器加载异常，建议您关闭<br/>耗带宽的软件后重试，或联系您的网络运营商。")
                    });
                    G_PLAYER_INIT.attachEvent(G_PLAYER_INIT, "onFlashError", function () {
                        a.error('检测到您没有安装Flash插件，您可以点这里 <a style=\'color:#1874CA;text-decoration: none;\' href="http://get.adobe.com/cn/flashplayer/" target="_blank">安装插件</a>')
                    })
                },
                stat: function (a) {
                    var a = a || {},
                        b = [];
                    a.p = "XCVP";
                    if (typeof a.u == "undefined") a.u = this.user.u || 0;
                    if (typeof a.v == "undefined") a.v = this.user.v || 0;
                    if (typeof a.from == "undefined") a.from = y || "XCVP";
                    if (typeof a.d == "undefined") a.d = D;
                    for (var c in a) b.push(c + "=" + encodeURIComponent(a[c]));
                    try {
                        setTimeout(function () {
                            (new Image(0, 0)).src = "http://i.vod.xunlei.com/stat/s.gif?" + b.join("&")
                        }, 5)
                    } catch (d) {}
                },
                stats_buff_flag: !1,
                stats_buff: function () {
                    if (!this.stats_buff_flag) {
                        var a = this.$PU("g", this.lastDlUrl),
                            b = this.curPlay.src_info.gcid || "";
                        this.stat({
                            f: "firstbuffer",
                            time: (new Date).getTime() - this.initTime,
                            gcid: a,
                            ygcid: b
                        });
                        this.stats_buff_flag = true;
                        try {
                            var c = G_PLAYER_INSTANCE.getFlashVer()
                        } catch (d) {
                            c = "unknown"
                        }
                        this.stat({
                            f: "flashversion",
                            flashversion: c
                        });
                        (document.location.host == ips[0] || document.location.host == ips[2]) && this.uVipinfo()
                    }
                },
                query: function (a, b, c, d, e, i) {
                    var h = this,
                        f = true;
                    h.getFileList();
                    var g = setTimeout(function () {
                        i ? G_PLAYER_INSTANCE.playOtherFail(false) : f && h.error("服务器正忙，请稍后再试");
                        clearTimeout(g)
                    }, 3E4),
                        a = b ? "/ajax/xl_req_get_method_vod?ver=2.721&userid=" + h.user.u + "&vip=" + h.user.v + "&sessionid=" + h.user.s + "&url=" + encodeURIComponent(a) + "&video_name=" + encodeURIComponent(b) + "&platform=" + (r ? "1" : "0") : "/ajax/xl_req_get_method_vod?ver=2.721&userid=" + h.user.u + "&vip=" + h.user.v + "&sessionid=" + h.user.s + "&url=" + encodeURIComponent(a) + "&platform=" + (r ? "1" : "0");
                    c && d && e && (a = a + "&gcid=" + c + "&cid=" + d + "&filesize=" + e);
                    a = a + "&cache=" + (new Date).getTime() + "&from=" + y;
                    o(a, "XL_CLOUD_FX_INSTANCEqueryBack", function (a) {
                        clearTimeout(g);
                        f = false;
                        var b = setTimeout(function () {
                            i ? h.queryOtherBack(a.resp) : h.queryBack(a.resp);
                            clearTimeout(b)
                        }, 25)
                    })
                },
                queryBack: function (a) {
                    var b = this;
                    b.curPlay = a;
                    b.initPlayerEvent();
                    if (typeof a.status == "undefined" || a.status != 0) if (r || p == "url" || b.fileList == null || b.fileList.subfile_list.length < 1) if (a.ret == 6) this.error("该视频下载链接有误，无法播放");
                    else if (a.status == 2 && a.trans_wait) {
                        var c = "";
                        if (0 < a.trans_wait && a.trans_wait < 60) c = a.trans_wait + "秒";
                        else {
                            if (a.trans_wait == -1) {
                                // todo
                                this.error("该文件尚未转码，暂时无法估计转码时间");
                                return false
                            }
                            var d = parseInt(a.trans_wait / 60),
                                e = 0,
                                i = d,
                                f = 0;
                            if (d >= 60) {
                                e = parseInt(d / 60);
                                i = d - e * 60;
                                if (e >= 24) {
                                    f = parseInt(e / 24);
                                    e = e - f * 24
                                }
                            }
                            f && (c = c + (f + "天"));
                            e && (c = c + (e + "小时"));
                            i && (c = c + (i + "分钟"))
                        }
                        this.error("该资源转码还需大约" + c + "，<a href='http://vod.xunlei.com' target='_blank' style='color:#1874CA;'>查看进度</a>")
                    } else a.status == 1 ? this.error("该资源云端下载与转码需要较长时间，<a href='http://vod.xunlei.com' target='_blank' style='color:#1874CA;'>查看进度</a>") : this.error("服务器正忙，请稍后再试");
                    else {
                        v.attachEvent(v, "onload", function () {
                            b.initEvent();
                            b.$PU("debug") && G_PLAYER_INSTANCE.showDebug();
                            G_PLAYER_INSTANCE.playOtherFail(false);
                            G_PLAYER_INSTANCE.setCaptionParam({
                                description: "请选择字幕文件(*.srt、*.ass)",
                                extension: "*.srt;*.ass",
                                limitSize: 5242880,
                                uploadURL: "http://dynamic.vod.lixian.xunlei.com/interface/upload_file/?cid=" + E,
                                timeOut: "30"
                            });
                            b.setShareParam();
                            G_PLAYER_INSTANCE.setToolBarEnable({
                                enableShare: false,
                                enableFileList: l.enableFileList,
                                enableDownload: false,
                                enableSet: false,
                                enableCaption: false,
                                enableOpenWindow: l.enableOpenWindow
                            });
                            b.setFeeParam(0);
                            G_PLAYER_INSTANCE.setFileList(b.fileList, p, "")
                        });
                        c = k.getAttribute("id");
                        v.printObject(c, false, "100%", "600px");
                        try {
                            window[K].call()
                        } catch (j) {}
                    } else {
                        if (p == "url") {
                            b.getLastPos();
                            b.fileList = {
                                userid: b.user.u,
                                info_hash: "",
                                subfile_list: [{
                                    name: b.curPlay.src_info.file_name,
                                    index: -1,
                                    url_hash: b.curPlay.url_hash
                                }]
                            }
                        }
                        if (b.originalPlay == null) b.originalPlay = a;
                        b.cacheData = b.cacheReqData(b.cacheData, a, b.curPlay.url_hash);
                        b.curName = m(b.curPlay.src_info.file_name);
                        v.attachEvent(v, "onload", function () {
                            b.initEvent();
                            b.$PU("debug") && G_PLAYER_INSTANCE.showDebug();
                            var c = a.vodinfo_list;
                            b.vod_info = c;
                            b.initTime = (new Date).getTime();
                            var d = c.length;
                            if (d == 1 && (t == "g" || t == "c") || d == 2 && t == "c") t = "p";
                            b.startPlay(t == "g" ? c[1].vod_url : t == "c" ? c[2].vod_url : c[0].vod_url, t, b.lastPos);
                            b.getFormats();
                            G_PLAYER_INSTANCE.playOtherFail(true);
                            b.getCaption(a.src_info.gcid, a.src_info.cid);
                            b.setShareParam();
                            G_PLAYER_INSTANCE.setFileList(b.fileList, p, a.src_info.gcid)
                        });
                        c = k.getAttribute("id");
                        v.printObject(c, false, "100%", "600px");
                        try {
                            window[K].call()
                        } catch (g) {}
                    }
                    c = a.src_info ? a.src_info.gcid : "";
                    try {
                        b.stat({
                            f: "svrresp",
                            ret: a.ret,
                            pt: a.status,
                            gcid: c
                        })
                    } catch (n) {}
                },
                cacheReqData: function (a, b, c) {
                    var a = a || [],
                        d = a.length;
                    if (d > 0 && d < 6) {
                        for (var e = [], i = 0; i < d; i++) a[i].url_hash && a[i].url_hash != c && e.push(a[i]);
                        a = e
                    }
                    a.push(b);
                    a.length == 5 && a.shift();
                    return a
                },
                startPlay: function (a, b, c) {
                    c = c || 0;
                    this.lastFormat = b;
                    this.lastDlUrl = a;
                    if (r) {
                        G_PLAYER_INSTANCE.setUrl(a, c);
                        this.getFormats();
                        return true
                    }
                    var d = {
                        totalByte: 1
                    };
                    d.totalTime = parseInt(this.curPlay.duration / 1E6);
                    d.totalByte = parseInt(this.$PU("s", a));
                    d.sliceType = 0;
                    if (c && c > 0) d.start = c;
                    G_PLAYER_INSTANCE.stop();
                    G_PLAYER_INSTANCE.setToolBarEnable(l);
                    this.setFeeParam(1);
                    d.format = b;
                    C && this.enableKKVA();
                    G_PLAYER_INSTANCE.flashopen(a, true, false, A, d, 0)
                },
                playOther: function (a, b, c, d, e) {
                    if (!a) {
                        G_PLAYER_INSTANCE.playOtherFail(false);
                        G_PLAYER_INSTANCE.setToolBarEnable({
                            enableShare: false,
                            enableFileList: l.enableFileList,
                            enableDownload: false,
                            enableSet: false,
                            enableCaption: false,
                            enableOpenWindow: l.enableOpenWindow
                        })
                    }
                    var i = this;
                    A = true;
                    t = "p";
                    F = 0;
                    this.captionList = [];
                    i.curName = m(c);
                    i.reportPlayPos();
                    c = m(a).substring(5, m(a).lastIndexOf("/"));
                    z = "http://bt.box.n0808.com/" + c.substr(0, 2) + "/" + c.substr(38, 40) + "/" + c + ".torrent";
                    i.curUrl = a;
                    c = false;
                    if (i.cacheData) for (var f = null, j = i.cacheData.length, g = 0; g < j; g++) if (b && i.cacheData[g].url_hash == b && i.cacheData[g].status == 0) {
                        c = true;
                        f = i.cacheData[g];
                        break
                    }
                    i.getLastPos();
                    if (c) var k = setTimeout(function () {
                        i.queryOtherBack(f);
                        clearTimeout(k)
                    }, 30);
                    i.query(a, B, d, e, "", 1)
                },
                queryOtherBack: function (a) {
                    try {
                        window[M].call()
                    } catch (b) {}
                    this.curPlay = a;
                    if (a.status != 0) {
                        G_PLAYER_INSTANCE.playOtherFail(false);
                        this.setFeeParam(0);
                        G_PLAYER_INSTANCE.setToolBarEnable({
                            enableShare: false,
                            enableFileList: l.enableFileList,
                            enableDownload: false,
                            enableSet: false,
                            enableCaption: false,
                            enableOpenWindow: l.enableOpenWindow
                        })
                    } else {
                        this.cacheData = this.cacheReqData(this.cacheData, a, this.curPlay.url_hash);
                        var c = a.vodinfo_list;
                        this.vod_info = c;
                        this.initTime = (new Date).getTime();
                        this.startPlay(c[0].vod_url, t, this.lastPos);
                        this.getFormats();
                        G_PLAYER_INSTANCE.playOtherFail(true);
                        this.getCaption(a.src_info.gcid, a.src_info.cid);
                        this.setShareParam()

                    }
                    c = a.src_info ? a.src_info.gcid : "";
                    try {
                        this.stat({
                            f: "svrresp",
                            ret: a.ret,
                            pt: a.status,
                            gcid: c
                        })
                    } catch (d) {}
                },
                setFeeParam: function (a) {
                    var b = y;
                    if (this.isXlpan || this.isThunderBox) b = "xlpan";
                    if (a) {
                        var a = this.curPlay.src_info,
                            c = a.file_size || "";
                        G_PLAYER_INSTANCE.setFeeParam({
                            sessionid: this.user.s,
                            userid: this.user.u,
                            isvip: this.user.v,
                            gcid: a.gcid,
                            cid: "0000000000000000000000000000000000000000",
                            name: a.file_name,
                            url_hash: this.curPlay.url_hash,
                            from: b,
                            url: m(this.curUrl),
                            ygcid: a.gcid,
                            ycid: a.cid,
                            filesize: c
                        })
                    } else G_PLAYER_INSTANCE.setFeeParam({
                        sessionid: this.user.s,
                        userid: this.user.u,
                        isvip: this.user.v,
                        gcid: "",
                        cid: "0000000000000000000000000000000000000000",
                        name: "",
                        url_hash: "",
                        from: b,
                        url: m(this.curUrl),
                        index: this.curUrl.substr(parseInt(this.curUrl.lastIndexOf("/")) + 1, this.curUrl.length),
                        ygcid: "",
                        ycid: "",
                        filesize: ""
                    })
                },
                $PU: function (a, b) {
                    var b = typeof b == "undefined" ? location.href : b,
                        c = b.match(/[#|?]([^#]*)[#|?]?/),
                        b = "&" + (typeof c == "object" && !c ? "" : c[1]),
                        c = b.match(RegExp("&" + a + "=", "i"));
                    return typeof c == "object" && !c ? void 0 : b.substr(c.index + 1).split("&")[0].split("=")[1]
                },
                getFormats: function (a) {
                    var a = a || this.lastFormat,
                        b = {
                            c: {
                                checked: false,
                                enable: false
                            },
                            g: {
                                checked: false,
                                enable: false
                            },
                            p: {
                                checked: false,
                                enable: false
                            },
                            y: {
                                checked: false,
                                enable: false
                            }
                        };
                    b.g.enable = typeof this.vod_info[1] != "undefined";
                    b.c.enable = typeof this.vod_info[2] != "undefined";
                    b.p.enable = true;
                    b[a].checked = true;
                    G_PLAYER_INSTANCE.setFormats(b)
                },
                setFormats: function (a, b, c) {
                    b = G_PLAYER_INSTANCE.getPlayPosition();
                    a = this;
                    A = true;
                    a.stat({
                        f: "changeformat",
                        format: c,
                        lastformat: a.lastFormat,
                        gcid: a.curPlay.src_info.gcid
                    });
                    if (c == "p") {
                        try {
                            G_PLAYER_INSTANCE.close();
                            G_PLAYER_INSTANCE.closeNetStream()
                        } catch (d) {}
                        G_PLAYER_INSTANCE.setIsChangeQuality(true);
                        this.startPlay(this.vod_info[0].vod_url, "p", b, 1);
                        G_PLAYER_INSTANCE.setIsChangeQuality(false);
                        a.getFormats()
                    } else if (c == "g") {
                        try {
                            G_PLAYER_INSTANCE.close();
                            G_PLAYER_INSTANCE.closeNetStream()
                        } catch (e) {}
                        G_PLAYER_INSTANCE.setIsChangeQuality(true);
                        this.startPlay(this.vod_info[1].vod_url, "g", b, 1);
                        G_PLAYER_INSTANCE.setIsChangeQuality(false);
                        a.getFormats()
                    } else if (c == "c") {
                        try {
                            G_PLAYER_INSTANCE.close();
                            G_PLAYER_INSTANCE.closeNetStream()
                        } catch (f) {}
                        G_PLAYER_INSTANCE.setIsChangeQuality(true);
                        this.startPlay(this.vod_info[2].vod_url, "c", b, 1);
                        G_PLAYER_INSTANCE.setIsChangeQuality(false);
                        a.getFormats()
                    }
                },
                error: function (a) {
                    k.innerHTML = "<img src='http://vod.xunlei.com/img/play_bg.jpg' width='100%' height='100%' /><div style='position:absolute;left:0;top:46%;text-align:center;font-size:14px;color:#FFF;margin: 0;width:100%;height:22px;'>" + a + "</div>";
                    try {
                        window[N].call()
                    } catch (b) {}
                },
                close: function () {
                    try {
                        G_PLAYER_INSTANCE.close();
                        G_PLAYER_INSTANCE.closeNetStream()
                    } catch (a) {}
                },
                getCaption: function (a, b) {
                    if (r) return true;
                    var c = this;
                    H("http://i.vod.xunlei.com/subtitle/list/gcid/" + a + "/cid/" + b, "XL_CLOUD_FX_INSTANCEqueryCaptionBack", function (a) {
                        c.queryCaptionBack(a, b)
                    });
                    G_PLAYER_INSTANCE.setCaptionParam({
                        description: "请选择字幕文件(*.srt、*.ass)",
                        extension: "*.srt;*.ass",
                        limitSize: 5242880,
                        uploadURL: "http://dynamic.vod.lixian.xunlei.com/interface/upload_file/?cid=" + b,
                        timeOut: "30"
                    })
                },
                queryCaptionBack: function (a) {
                    var b = a.sublist.length;
                    if (a.sublist != void 0 && a.sublist.length > 0) {
                        for (var a = a.sublist, c = 0; c < b; c++) {
                            if (this.captionList.length > 3) break;
                            var d = a[c];
                            if (d.sname != void 0) {
                                var e = d.sname,
                                    f = e.length;
                                if (f > 0) for (var h = 0; h < f; h++) {
                                    var j = m(e[h]),
                                        g = j.lastIndexOf("."),
                                        k = j.length,
                                        g = j.substring(parseInt(g) + 1, k).toLowerCase();
                                    if (g == "ass" || g == "srt") this.captionList.push({
                                        language: d.language[0] || "",
                                        scid: d.scid,
                                        sname: j,
                                        surl: "http://i.vod.xunlei.com/subtitle/data/scid/" + d.scid + ".srt",
                                        svote: d.svote || 0
                                    })
                                }
                            }
                        }
                        r || G_PLAYER_INSTANCE.setCaptionList(this.captionList)
                    }
                },
                addCaptionList: function (a) {
                    var b = a.length;
                    if (!a || typeof a != "object" || b < 1) return false;
                    for (var c = 0; c < b; c++) {
                        if (c == 1) break;
                        this.captionList.push(a[c])
                    }
                    this.captionList.length > 3 && this.captionList.shift();
                    G_PLAYER_INSTANCE.setCaptionList(this.captionList)
                },
                getFileList: function () {
                    var a = this;
                    if (p == "url" || u.length != 40) return a.fileList = null;
                    if (a.fileList == null || a.fileList.ret != 0) {
                        var b = "http://i.vod.xunlei.com/req_subBT/info_hash/" + u + "/req_num/200/req_offset/0?cache=" + (new Date).getTime();
                        o(b, "XL_CLOUD_FX_INSTANCEqueryFileListBack", function (b) {
                            clearTimeout(null);
                            a.fileList = b.resp;
                            if (a.fileList.ret == 0) {
                                a.fileList.subfile_list.length > 199 && o("http://i.vod.xunlei.com/req_subBT/info_hash/" + u + "/req_num/200/req_offset/200?cache=" + (new Date).getTime(), "XL_CLOUD_FX_INSTANCEqueryFileListBack", function (b) {
                                    clearTimeout(null);
                                    b = b.resp;
                                    if (b.ret == 0) a.fileList.subfile_list = a.fileList.subfile_list.concat(b.subfile_list)
                                });
                                a.getLastPos()
                            }
                        })
                    }
                },
                download: function (a) {
                    if (!x) {
                        alert("暂不支持非IE内核浏览器，请换用IE浏览器下载");
                        return false
                    }
                    var b = this,
                        c = "",
                        d = "",
                        d = b.curName;
                    if (a == "y") {
                        turl = j.toLowerCase();
                        if (turl.indexOf("xlpan") != -1) {
                            var e = null,
                                f = true;
                            o("http://i.vod.xunlei.com/vod_dl_xlpan?userid=" + b.user.u + "&url=" + encodeURIComponent(j), "tttttt", function (a) {
                                f = false;
                                clearTimeout(e);
                                a.url ? b.thunder(b.curPlay.src_info.gcid, a.url, d) : alert("对不起暂时无法获取该下载链接。")
                            });
                            e = setTimeout(function () {
                                f && alert("对不起暂时无法获取该下载链接。");
                                clearTimeout(e)
                            }, 3E4);
                            return false
                        }
                        c = p == "bt" ? L : j;
                        b.thunder(b.curPlay.src_info.gcid, c, d)
                    } else {
                        var h = "",
                            c = "",
                            k = d,
                            g = "",
                            m = h = "",
                            l = "225536";
                        if (a == "p" && b.vod_info[0].vod_url) {
                            h = b.vod_info[0].vod_url;
                            l = b.vod_info[0].spec_id
                        } else if (a == "g" && b.vod_info[1].vod_url) {
                            h = b.vod_info[1].vod_url;
                            l = b.vod_info[1].spec_id
                        } else if (a == "c" && b.vod_info[2].vod_url) {
                            h = b.vod_info[2].vod_url;
                            l = b.vod_info[2].spec_id
                        } else return false;
                        c = b.$PU("g", h);
                        g = b.$PU("scn", h);
                        m = b.$PU("s", h);
                        h = b.$PU("ui", h);
                        e = null;
                        f = true;
                        o("http://i.vod.xunlei.com/vod_dl?userid=" + h + "&gcid=" + c + "&cid=0000000000000000000000000000000000000000&filesize=" + m + "&section=" + g + "&trans_id=" + l + "&filename=" + encodeURIComponent(k), "tttttt", function (a) {
                            f = false;
                            clearTimeout(e);
                            a.url ? b.thunder("", a.url, a.filename) : alert("对不起暂时无法获取该下载链接。")
                        });
                        e = setTimeout(function () {
                            f && alert("对不起暂时无法获取该下载链接。");
                            clearTimeout(e)
                        }, 3E4);
                        return false
                    }
                },
                thunder: function (a, b, c) {
                    if (x) try {
                        var d = new Thunder;
                        d._$ ? d.down(a, b, window.location.href, m(c)) : alert("请先安装迅雷7")
                    } catch (e) {
                        alert("请先安装迅雷7")
                    } else alert("暂不支持非IE内核浏览器，请换用IE浏览器下载")
                },
                setShareParam: function () {
                    var a = "我正在观看" + m(B);
                    G_PLAYER_INSTANCE.setShareParam(a, z)
                },
                loginNotice: function () {
                    window.open("http://vod.xunlei.com/home.html?xcvp=login");
                    this.error("继续<a style='color:#1874CA' href='javascript:;' onclick='XL_CLOUD_FX_INSTANCE.continuePlay();return false;'>播放</a>")
                },
                continuePlay: function () {
                    this.error("请稍候，精彩即将开启...");
                    this.uCheck()
                },
                getLastPos: function () {
                    return false;
                    var a = this;
                    if (F) {
                        a.lastPos = F;
                        return true
                    }
                    a.lastPos = 0;
                    if (p == "bt") var b = a.curUrl.substr(a.curUrl.lastIndexOf("/") + 1, a.curUrl.length),
                        c = a.fileList.main_task_url_hash;
                    else c = a.curPlay.url_hash;
                    o("http://i.vod.xunlei.com/req_last_play_pos?userid=" + a.user.u + "&query_list=" + c + "_" + (p == "bt" ? 1 : 0) + "&t=" + (new Date).getTime(), "XL_CLOUD_FX_INSTANCEqueryLastPosBack", function (c) {
                        clearTimeout(null);
                        if (c.resp && c.resp.ret == 0) {
                            var e = c.resp.res_list;
                            if (e && e[0]) if (e[0].is_bt_play == 0) a.lastPos = e[0].last_play_pos;
                            else if (e[0].sub_list && e[0].sub_list.length > 0) for (var c = e[0].sub_list, e = e[0].sub_list.length, f = 0; f < e; f++) if (c[f].idx == b) {
                                a.lastPos = c[f].last_play_pos;
                                break
                            }
                        }
                    });
                    setTimeout(function () {
                        clearTimeout(null)
                    }, 1E3)
                },
                validUrl: function (a) {
                    if (a == "" || a == "none" || a == "undefined" || document.location.protocol + "//" + document.location.host + "/" == a) return false;
                    a = a.toLowerCase();
                    return a.indexOf("http") == -1 && a.indexOf("https") == -1 && a.indexOf("ftp") == -1 && a.indexOf("thunder") == -1 && a.indexOf("mms") == -1 && a.indexOf("rtsp") == -1 && a.indexOf("magnet") == -1 && a.indexOf("flashget") == -1 && a.indexOf("qqdl") == -1 && a.indexOf("ed2k") == -1 && a.indexOf("bt") == -1 && a.indexOf("xlpan") == -1 || a == "" ? false : true
                },
                windowOpenInPlayer: function (a) {
                    var b = document;
                    _body = document.getElementsByTagName("body")[0];
                    var c = null,
                        d = b.getElementById("dapctrl");
                    if (d) try {
                        b.getElementsByTagName("body")[0].removeChild(d)
                    } catch (e) {}
                    if (!x && !b.getElementById("dapctrl")) {
                        b = b.createElement("object");
                        b.setAttribute("type", "application/x-thunder-dapctrl");
                        b.setAttribute("id", "dapctrl");
                        b.setAttribute("width", "0");
                        b.setAttribute("height", "0");
                        b.style.visibility = "hidden";
                        _body.appendChild(b)
                    } else try {
                        c = new ActiveXObject("DapCtrl.DapCtrl")
                    } catch (f) {}
                    if (c) {
                        c.Put("iADShowMode", 1);
                        c.Put("sOpenAdUrl", a)
                    } else window.open(a)
                },
                openMini: function (a) {
                    try {
                        this.reportPlayPos()
                    } catch (b) {}
                    this.stat({
                        f: "openmini"
                    });
                    window.open("http://" + goip + "/player.html?" + a, "miniplayer", "top=10,left=10,height=446,width=684,toolbar=no,menubar=no,resizable=yes,scrollbars=no,location=no,status=no,fullscreen=no")
                },
                enableKKVA: function () {
                    this.kkvaValid = false;
                    if (r || !this.isThunderBox && !x) return true;
                    var a = document.getElementsByTagName("body")[0],
                        b = document.getElementById("vasensor");
                    try {
                        a.removeChild(b)
                    } catch (c) {}
                    a = document.createElement("object");
                    a.setAttribute("id", "vasensor");
                    a.setAttribute("width", "0");
                    a.setAttribute("height", "0");
                    a.style.visibility = "hidden";
                    x ? a.setAttribute("classid", "CLSID:96CD6DA7-17F2-4576-82B0-BE4526FB7D6B") : a.setAttribute("type", "application/x-thunder-kkva");
                    document.getElementsByTagName("body")[0].appendChild(a);
                    b = 0;
                    XL_CLOUD_FX_INSTANCE.lastFormat == "c" ? b = 2 : XL_CLOUD_FX_INSTANCE.lastFormat == "g" && (b = 1);
                    var b = XL_CLOUD_FX_INSTANCE.vod_info[b].vod_url,
                        d = this.$PU("g", b);
                    if (this.isThunderBox) {
                        try {
                            var e = window.external.GetClientVersion()
                        } catch (f) {
                            e = "1.6"
                        }
                        if (e < "1.6") try {
                            G_PLAYER_INSTANCE.setNoticeMsg("推荐安装迅雷方舟客户端享加速流畅播放体验  <a href=\"javascript:XL_CLOUD_FX_INSTANCE.windowOpenInPlayer('http://down.sandai.net/xlpan/ThunderboxSetup.exe')\">立即下载</a>", 30)
                        } catch (h) {} else try {
                            if (a.Get("iVersion") != 100007) {
                                a.EnableVA("yvod", d, b, 0);
                                this.kkvaValid = true;
                                a.Put("iXMPIconTray", 0)
                            }
                        } catch (j) {}
                    } else try {
                        var g = document.getElementById("myPlugin");
                        if (!g) {
                            g = document.createElement("object");
                            g.setAttribute("id", "myPlugin");
                            g.setAttribute("width", "0");
                            g.setAttribute("height", "0");
                            g.style.visibility = "hidden";
                            x ? g.setAttribute("classid", "clsid:BD1E9B61-F3B2-4A19-AB69-68E77CA81C42") : g.setAttribute("type", "application/x-thunderbox-upload");
                            document.getElementsByTagName("body")[0].appendChild(g)
                        }
                        if (g.FindThunderbox() && g.GetThunderboxVersion() >= "1.6" && a.Get("iVersion") != 100007) {
                            a.EnableVA("yvod", d, b, 0);
                            this.kkvaValid = true;
                            a.Put("iXMPIconTray", 0)
                        } else if (g.GetThunderboxVersion() < "1.6") try {
                            G_PLAYER_INSTANCE.setNoticeMsg("推荐安装迅雷方舟客户端享加速流畅播放体验  <a href=\"javascript:XL_CLOUD_FX_INSTANCE.windowOpenInPlayer('http://down.sandai.net/xlpan/ThunderboxSetup.exe')\">立即下载</a>", 30)
                        } catch (k) {}
                    } catch (l) {
                        try {
                            G_PLAYER_INSTANCE.setNoticeMsg("推荐安装迅雷方舟客户端享加速流畅播放体验  <a href=\"javascript:XL_CLOUD_FX_INSTANCE.windowOpenInPlayer('http://down.sandai.net/xlpan/ThunderboxSetup.exe')\">立即下载</a>", 30)
                        } catch (m) {}
                    }
                    return true
                }
            };
            o("http://dynamic.vod.lixian.xunlei.com/fx?t=" + (new Date).getTime(), "", function () {
                return false
            });
            f = new s(r ? "http://vod.xunlei.com/fx/ipad.js?1.22" : "http://vod.xunlei.com/fx/flash.js?1.22");
            f.buildScriptTag();
            f.addScriptTag();
            r || (f = new s("http://vod.xunlei.com/fx/thunder.js?1.22"), f.buildScriptTag(), f.addScriptTag())
        }
    }, 1)
})();