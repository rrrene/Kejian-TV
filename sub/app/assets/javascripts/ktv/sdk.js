/*!
 * jQuery JavaScript Library v1.7.2
 * http://jquery.com/
 *
 * Copyright 2011, John Resig
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 *
 * Includes Sizzle.js
 * http://sizzlejs.com/
 * Copyright 2011, The Dojo Foundation
 * Released under the MIT, BSD, and GPL Licenses.
 *
 * Date: Wed Mar 21 12:46:34 2012 -0700
 */
if(!window.KTV){window.KTV={}}

function showProcessProgress(a) {
  (function($){
    $.ajax({
        url: "/presentations/" + a + "/status",
        dataType: "json",
        success: function (b) {
            b.complete < b.total ? ($("[data-processing-presentation=" + a + "]",'.__sdk').html(b.html), setTimeout(function () {
                showProcessProgress(a)
            }, 2e3)) : b.complete === undefined || b.total == 0 ? setTimeout(function () {
                showProcessProgress(a)
            }, 2e3) : setTimeout(function () {
                $("#upload h1",'.__sdk').text("课件预览");
                $("#reupload",'.__sdk').hide();
                $("#presentation_" + a,'.__sdk').html("").parent().addClass("slide_frame");
                $(".slide_frame.processing",'.__sdk').removeClass("processing");
                $("body").append("<script type='text/javascript' src='/embed/" + b.id + ".js?container=presentation_" + a + "'></scr" + "ipt>")
            }, 2e3)
        }
    })
  })(jQuery)
}


// P.S.V.R sensed(tm)
// QQUploader

var qq = qq || {};
qq.extend = function (a, b) {
    for (var c in b) a[c] = b[c]
}, qq.indexOf = function (a, b, c) {
    if (a.indexOf) return a.indexOf(b, c);
    c = c || 0;
    var d = a.length;
    c < 0 && (c += d);
    for (; c < d; c++) if (c in a && a[c] === b) return c;
    return -1
}, qq.getUniqueId = function () {
    var a = 0;
    return function () {
        return a++
    }
}(), qq.attach = function (a, b, c) {
    a.addEventListener ? a.addEventListener(b, c, !1) : a.attachEvent && a.attachEvent("on" + b, c)
}, qq.detach = function (a, b, c) {
    a.removeEventListener ? a.removeEventListener(b, c, !1) : a.attachEvent && a.detachEvent("on" + b, c)
}, qq.preventDefault = function (a) {
    a.preventDefault ? a.preventDefault() : a.returnValue = !1
}, qq.insertBefore = function (a, b) {
    b.parentNode.insertBefore(a, b)
}, qq.remove = function (a) {
    a.parentNode.removeChild(a)
}, qq.contains = function (a, b) {
    return a == b ? !0 : a.contains ? a.contains(b) : !! (b.compareDocumentPosition(a) & 8)
}, qq.toElement = function () {
    var a = document.createElement("div");
    return function (b) {
        a.innerHTML = b;
        var c = a.firstChild;
        return a.removeChild(c), c
    }
}(), qq.css = function (a, b) {
    b.opacity != null && typeof a.style.opacity != "string" && typeof a.filters != "undefined" && (b.filter = "alpha(opacity=" + Math.round(100 * b.opacity) + ")"), qq.extend(a.style, b)
}, qq.hasClass = function (a, b) {
    var c = new RegExp("(^| )" + b + "( |$)");
    return c.test(a.className)
}, qq.addClass = function (a, b) {
    qq.hasClass(a, b) || (a.className += " " + b)
}, qq.removeClass = function (a, b) {
    var c = new RegExp("(^| )" + b + "( |$)");
    a.className = a.className.replace(c, " ").replace(/^\s+|\s+$/g, "")
}, qq.setText = function (a, b) {
    a.innerText = b, a.textContent = b
}, qq.children = function (a) {
    var b = [],
        c = a.firstChild;
    while (c) c.nodeType == 1 && b.push(c), c = c.nextSibling;
    return b
}, qq.getByClass = function (a, b) {
    if (a.querySelectorAll) return a.querySelectorAll("." + b);
    var c = [],
        d = a.getElementsByTagName("*"),
        e = d.length;
    for (var f = 0; f < e; f++) qq.hasClass(d[f], b) && c.push(d[f]);
    return c
}, qq.obj2url = function (a, b, c) {
    var d = [],
        e = "&",
        f = function (a, c) {
            var e = b ? /\[\]$/.test(b) ? b : b + "[" + c + "]" : c;
            e != "undefined" && c != "undefined" && d.push(typeof a == "object" ? qq.obj2url(a, e, !0) : Object.prototype.toString.call(a) === "[object Function]" ? encodeURIComponent(e) + "=" + encodeURIComponent(a()) : encodeURIComponent(e) + "=" + encodeURIComponent(a))
        };
    if (!c && b) e = /\?/.test(b) ? /\?$/.test(b) ? "" : "&" : "?", d.push(b), d.push(qq.obj2url(a));
    else if (Object.prototype.toString.call(a) === "[object Array]" && typeof a != "undefined") for (var g = 0, h = a.length; g < h; ++g) f(a[g], g);
    else if (typeof a != "undefined" && a !== null && typeof a == "object") for (var g in a) f(a[g], g);
    else d.push(encodeURIComponent(b) + "=" + encodeURIComponent(a));
    return d.join(e).replace(/^&/, "").replace(/%20/g, "+")
};
var qq = qq || {};
qq.FileUploaderBasic = function (a) {
    this._options = {
        debug: !1,
        action: "/server/upload",
        requestType: "POST",
        params: {},
        button: null,
        multiple: !0,
        maxConnections: 3,
        allowedExtensions: [],
        sizeLimit: 0,
        minSizeLimit: 0,
        onSubmit: function (a, b) {},
        onProgress: function (a, b, c, d) {},
        onComplete: function (a, b, c) {},
        onCancel: function (a, b) {},
        messages: {
            typeError: "{file} has invalid extension. Only {extensions} are allowed.",
            sizeError: "{file} is too large, maximum file size is {sizeLimit}.",
            minSizeError: "{file} is too small, minimum file size is {minSizeLimit}.",
            emptyError: "{file} is empty, please select files again without it.",
            onLeave: "The files are being uploaded, if you leave now the upload will be cancelled."
        },
        showMessage: function (a) {
            alert(a)
        }
    }, qq.extend(this._options, a), this._filesInProgress = 0, this._handler = this._createUploadHandler(), this._options.button && (this._button = this._createUploadButton(this._options.button)), this._preventLeaveInProgress()
}, qq.FileUploaderBasic.prototype = {
    setParams: function (a) {
        this._options.params = a
    },
    getInProgress: function () {
        return this._filesInProgress
    },
    _createUploadButton: function (a) {
        var b = this;
        return new qq.UploadButton({
            element: a,
            multiple: this._options.multiple && qq.UploadHandlerXhr.isSupported(),
            onChange: function (a) {
                b._onInputChange(a)
            }
        })
    },
    _createUploadHandler: function () {
        var a = this,
            b;
        qq.UploadHandlerXhr.isSupported() ? b = "UploadHandlerXhr" : b = "UploadHandlerForm";
        var c = new qq[b]({
            debug: this._options.debug,
            action: this._options.action,
            requestType: this._options.requestType,
            maxConnections: this._options.maxConnections,
            onProgress: function (b, c, d, e) {
                a._onProgress(b, c, d, e), a._options.onProgress(b, c, d, e)
            },
            onComplete: function (b, c, d) {
                a._onComplete(b, c, d), a._options.onComplete(b, c, d)
            },
            onCancel: function (b, c) {
                a._onCancel(b, c), a._options.onCancel(b, c)
            }
        });
        return c
    },
    _preventLeaveInProgress: function () {
        var a = this;
        qq.attach(window, "beforeunload", function (b) {
            if (!a._filesInProgress) return;
            var b = b || window.event;
            return b.returnValue = a._options.messages.onLeave, a._options.messages.onLeave
        })
    },
    _onSubmit: function (a, b) {
        this._filesInProgress++
    },
    _onProgress: function (a, b, c, d) {},
    _onComplete: function (a, b, c) {
        this._filesInProgress--, c.error && this._options.showMessage(c.error)
    },
    _onCancel: function (a, b) {
        this._filesInProgress--
    },
    _onInputChange: function (a) {
        this._handler instanceof qq.UploadHandlerXhr ? this._uploadFileList(a.files) : this._validateFile(a) && this._uploadFile(a), this._button.reset()
    },
    _uploadFileList: function (a) {
        for (var b = 0; b < a.length; b++) if (!this._validateFile(a[b])) return;
        for (var b = 0; b < a.length; b++) this._uploadFile(a[b])
    },
    _uploadFile: function (a) {
        var b = this._handler.add(a),
            c = this._handler.getName(b);
        this._options.onSubmit(b, c) !== !1 && (this._onSubmit(b, c), this._handler.upload(b, this._options.params))
    },
    _validateFile: function (a) {
        var b, c;
        return a.value ? b = a.value.replace(/.*(\/|\\)/, "") : (b = a.fileName != null ? a.fileName : a.name, c = a.fileSize != null ? a.fileSize : a.size), this._isAllowedExtension(b) ? c === 0 ? (this._error("emptyError", b), !1) : c && this._options.sizeLimit && c > this._options.sizeLimit ? (this._error("sizeError", b), !1) : c && c < this._options.minSizeLimit ? (this._error("minSizeError", b), !1) : !0 : (this._error("typeError", b), !1)
    },
    _error: function (a, b) {function d(a, b) {
            c = c.replace(a, b)
        }
        var c = this._options.messages[a];
        d("{file}", this._formatFileName(b)), d("{extensions}", this._options.allowedExtensions.join(", ")), d("{sizeLimit}", this._formatSize(this._options.sizeLimit)), d("{minSizeLimit}", this._formatSize(this._options.minSizeLimit)), this._options.showMessage(c)
    },
    _formatFileName: function (a) {
        return a.length > 33 && (a = a.slice(0, 19) + "..." + a.slice(-13)), a
    },
    _isAllowedExtension: function (a) {
        var b = -1 !== a.indexOf(".") ? a.replace(/.*[.]/, "").toLowerCase() : "",
            c = this._options.allowedExtensions;
        if (!c.length) return !0;
        for (var d = 0; d < c.length; d++) if (c[d].toLowerCase() == b) return !0;
        return !1
    },
    _formatSize: function (a) {
        var b = -1;
        do a /= 1024, b++;
        while (a > 99);
        return Math.max(a, .1).toFixed(1) + ["kB", "MB", "GB", "TB", "PB", "EB"][b]
    }
}, qq.FileUploader = function (a) {
    qq.FileUploaderBasic.apply(this, arguments), qq.extend(this._options, {
        element: null,
        listElement: null,
        template: '<div class="qq-uploader"><div class="qq-upload-drop-area"><span>Drop files here to upload</span></div><div class="qq-upload-button">请选择源文件</div><ul class="qq-upload-list"></ul></div>',
        fileTemplate: '<li><span class="qq-upload-file"></span><span class="qq-upload-spinner"></span><span class="qq-upload-size"></span><a class="qq-upload-cancel" href="#">Cancel</a><span class="qq-upload-failed-text">Failed</span></li>',
        classes: {
            button: "qq-upload-button",
            drop: "qq-upload-drop-area",
            dropActive: "qq-upload-drop-area-active",
            list: "qq-upload-list",
            file: "qq-upload-file",
            spinner: "qq-upload-spinner",
            size: "qq-upload-size",
            cancel: "qq-upload-cancel",
            success: "qq-upload-success",
            fail: "qq-upload-fail"
        }
    }), qq.extend(this._options, a), this._element = this._options.element, this._element.innerHTML = this._options.template, this._listElement = this._options.listElement || this._find(this._element, "list"), this._classes = this._options.classes, this._button = this._createUploadButton(this._find(this._element, "button")), this._bindCancelEvent(), this._setupDragDrop()
}, qq.extend(qq.FileUploader.prototype, qq.FileUploaderBasic.prototype), qq.extend(qq.FileUploader.prototype, {
    _find: function (a, b) {
        var c = qq.getByClass(a, this._options.classes[b])[0];
        if (!c) throw new Error("element not found " + b);
        return c
    },
    _setupDragDrop: function () {
        var a = this,
            b = this._find(this._element, "drop"),
            c = new qq.UploadDropZone({
                element: b,
                onEnter: function (c) {
                    qq.addClass(b, a._classes.dropActive), c.stopPropagation()
                },
                onLeave: function (a) {
                    a.stopPropagation()
                },
                onLeaveNotDescendants: function (c) {
                    qq.removeClass(b, a._classes.dropActive)
                },
                onDrop: function (c) {
                    b.style.display = "none", qq.removeClass(b, a._classes.dropActive), a._uploadFileList(c.dataTransfer.files)
                }
            });
        b.style.display = "none", qq.attach(document, "dragenter", function (a) {
            if (!c._isValidFileDrag(a)) return;
            b.style.display = "block"
        }), qq.attach(document, "dragleave", function (a) {
            if (!c._isValidFileDrag(a)) return;
            var d = document.elementFromPoint(a.clientX, a.clientY);
            if (!d || d.nodeName == "HTML") b.style.display = "none"
        })
    },
    _onSubmit: function (a, b) {
        qq.FileUploaderBasic.prototype._onSubmit.apply(this, arguments), this._addToList(a, b)
    },
    _onProgress: function (a, b, c, d) {
        qq.FileUploaderBasic.prototype._onProgress.apply(this, arguments);
        var e = this._getItemByFileId(a),
            f = this._find(e, "size");
        f.style.display = "inline";
        var g;
        c != d ? g = Math.round(c / d * 100) + "% from " + this._formatSize(d) : g = this._formatSize(d), qq.setText(f, g)
    },
    _onComplete: function (a, b, c) {
        qq.FileUploaderBasic.prototype._onComplete.apply(this, arguments);
        var d = this._getItemByFileId(a);
        qq.remove(this._find(d, "cancel")), qq.remove(this._find(d, "spinner")), c.success ? qq.addClass(d, this._classes.success) : qq.addClass(d, this._classes.fail)
    },
    _addToList: function (a, b) {
        var c = qq.toElement(this._options.fileTemplate);
        c.qqFileId = a;
        var d = this._find(c, "file");
        qq.setText(d, this._formatFileName(b)), this._find(c, "size").style.display = "none", this._listElement.appendChild(c)
    },
    _getItemByFileId: function (a) {
        var b = this._listElement.firstChild;
        while (b) {
            if (b.qqFileId == a) return b;
            b = b.nextSibling
        }
    },
    _bindCancelEvent: function () {
        var a = this,
            b = this._listElement;
        qq.attach(b, "click", function (b) {
            b = b || window.event;
            var c = b.target || b.srcElement;
            if (qq.hasClass(c, a._classes.cancel)) {
                qq.preventDefault(b);
                var d = c.parentNode;
                a._handler.cancel(d.qqFileId), qq.remove(d)
            }
        })
    }
}), qq.UploadDropZone = function (a) {
    this._options = {
        element: null,
        onEnter: function (a) {},
        onLeave: function (a) {},
        onLeaveNotDescendants: function (a) {},
        onDrop: function (a) {}
    }, qq.extend(this._options, a), this._element = this._options.element, this._disableDropOutside(), this._attachEvents()
}, qq.UploadDropZone.prototype = {
    _disableDropOutside: function (a) {
        qq.UploadDropZone.dropOutsideDisabled || (qq.attach(document, "dragover", function (a) {
            a.dataTransfer && (a.dataTransfer.dropEffect = "none", a.preventDefault())
        }), qq.UploadDropZone.dropOutsideDisabled = !0)
    },
    _attachEvents: function () {
        var a = this;
        qq.attach(a._element, "dragover", function (b) {
            if (!a._isValidFileDrag(b)) return;
            var c = b.dataTransfer.effectAllowed;
            c == "move" || c == "linkMove" ? b.dataTransfer.dropEffect = "move" : b.dataTransfer.dropEffect = "copy", b.stopPropagation(), b.preventDefault()
        }), qq.attach(a._element, "dragenter", function (b) {
            if (!a._isValidFileDrag(b)) return;
            a._options.onEnter(b)
        }), qq.attach(a._element, "dragleave", function (b) {
            if (!a._isValidFileDrag(b)) return;
            a._options.onLeave(b);
            var c = document.elementFromPoint(b.clientX, b.clientY);
            if (qq.contains(this, c)) return;
            a._options.onLeaveNotDescendants(b)
        }), qq.attach(a._element, "drop", function (b) {
            if (!a._isValidFileDrag(b)) return;
            b.preventDefault(), a._options.onDrop(b)
        })
    },
    _isValidFileDrag: function (a) {
        var b = a.dataTransfer,
            c = navigator.userAgent.indexOf("AppleWebKit") > -1;
        return b && b.effectAllowed != "none" && (b.files || !c && b.types.contains && b.types.contains("Files"))
    }
}, qq.UploadButton = function (a) {
    this._options = {
        element: null,
        multiple: !1,
        name: "file",
        onChange: function (a) {},
        hoverClass: "qq-upload-button-hover",
        focusClass: "qq-upload-button-focus"
    }, qq.extend(this._options, a), this._element = this._options.element, qq.css(this._element, {
        position: "relative",
        overflow: "hidden",
        direction: "ltr"
    }), this._input = this._createInput()
}, qq.UploadButton.prototype = {
    getInput: function () {
        return this._input
    },
    reset: function () {
        this._input.parentNode && qq.remove(this._input), qq.removeClass(this._element, this._options.focusClass), this._input = this._createInput()
    },
    _createInput: function () {
        var a = document.createElement("input");
        this._options.multiple && a.setAttribute("multiple", "multiple"), a.setAttribute("type", "file"), a.setAttribute("name", this._options.name), qq.css(a, {
            position: "absolute",
            right: 0,
            top: 0,
            fontFamily: "Arial",
            fontSize: "118px",
            margin: 0,
            padding: 0,
            cursor: "pointer",
            opacity: 0
        }), this._element.appendChild(a);
        var b = this;
        return qq.attach(a, "change", function () {
            b._options.onChange(a)
        }), qq.attach(a, "mouseover", function () {
            qq.addClass(b._element, b._options.hoverClass)
        }), qq.attach(a, "mouseout", function () {
            qq.removeClass(b._element, b._options.hoverClass)
        }), qq.attach(a, "focus", function () {
            qq.addClass(b._element, b._options.focusClass)
        }), qq.attach(a, "blur", function () {
            qq.removeClass(b._element, b._options.focusClass)
        }), window.attachEvent && a.setAttribute("tabIndex", "-1"), a
    }
}, qq.UploadHandlerAbstract = function (a) {
    this._options = {
        debug: !1,
        action: "/upload.php",
        maxConnections: 999,
        onProgress: function (a, b, c, d) {},
        onComplete: function (a, b, c) {},
        onCancel: function (a, b) {}
    }, qq.extend(this._options, a), this._queue = [], this._params = []
}, qq.UploadHandlerAbstract.prototype = {
    log: function (a) {
        this._options.debug && window.console && console.log("[uploader] " + a)
    },
    add: function (a) {},
    upload: function (a, b) {
        var c = this._queue.push(a),
            d = {};
        qq.extend(d, b), this._params[a] = d, c <= this._options.maxConnections && this._upload(a, this._params[a])
    },
    cancel: function (a) {
        this._cancel(a), this._dequeue(a)
    },
    cancelAll: function () {
        for (var a = 0; a < this._queue.length; a++) this._cancel(this._queue[a]);
        this._queue = []
    },
    getName: function (a) {},
    getSize: function (a) {},
    getQueue: function () {
        return this._queue
    },
    _upload: function (a) {},
    _cancel: function (a) {},
    _dequeue: function (a) {
        var b = qq.indexOf(this._queue, a);
        this._queue.splice(b, 1);
        var c = this._options.maxConnections;
        if (this._queue.length >= c) {
            var d = this._queue[c - 1];
            this._upload(d, this._params[d])
        }
    }
}, qq.UploadHandlerForm = function (a) {
    qq.UploadHandlerAbstract.apply(this, arguments), this._inputs = {}
}, qq.extend(qq.UploadHandlerForm.prototype, qq.UploadHandlerAbstract.prototype), qq.extend(qq.UploadHandlerForm.prototype, {
    add: function (a) {
        a.setAttribute("name", "qqfile");
        var b = "qq-upload-handler-iframe" + qq.getUniqueId();
        return this._inputs[b] = a, a.parentNode && qq.remove(a), b
    },
    getName: function (a) {
        return this._inputs[a].value.replace(/.*(\/|\\)/, "")
    },
    _cancel: function (a) {
        this._options.onCancel(a, this.getName(a)), delete this._inputs[a];
        var b = document.getElementById(a);
        b && (b.setAttribute("src", "javascript:false;"), qq.remove(b))
    },
    _upload: function (a, b) {
        var c = this._inputs[a];
        if (!c) throw new Error("file with passed id was not added, or already uploaded or cancelled");
        var d = this.getName(a),
            e = this._createIframe(a),
            f = this._createForm(e, b);
        f.appendChild(c);
        var g = this;
        return this._attachLoadEvent(e, function () {
            g.log("iframe loaded");
            var b = g._getIframeContentJSON(e);
            g._options.onComplete(a, d, b), g._dequeue(a), delete g._inputs[a], setTimeout(function () {
                qq.remove(e)
            }, 1)
        }), f.submit(), qq.remove(f), a
    },
    _attachLoadEvent: function (a, b) {
        qq.attach(a, "load", function () {
            if (!a.parentNode) return;
            if (a.contentDocument && a.contentDocument.body && a.contentDocument.body.innerHTML == "false") return;
            b()
        })
    },
    _getIframeContentJSON: function (iframe) {
        var doc = iframe.contentDocument ? iframe.contentDocument : iframe.contentWindow.document,
            response;
        this.log("converting iframe's innerHTML to JSON"), this.log("innerHTML = " + doc.body.innerHTML);
        try {
            response = eval("(" + doc.body.innerHTML + ")")
        } catch (err) {
            response = {}
        }
        return response
    },
    _createIframe: function (a) {
        var b = qq.toElement('<iframe src="javascript:false;" name="' + a + '" />');
        return b.setAttribute("id", a), b.style.display = "none", document.body.appendChild(b), b
    },
    _createForm: function (a, b) {
        var c = qq.toElement('<form method="post" enctype="multipart/form-data"></form>'),
            d = qq.obj2url(b, this._options.action);
        return c.setAttribute("action", d), c.setAttribute("target", a.name), c.style.display = "none", document.body.appendChild(c), c
    }
}), qq.UploadHandlerXhr = function (a) {
    qq.UploadHandlerAbstract.apply(this, arguments), this._files = [], this._xhrs = [], this._loaded = []
}, qq.UploadHandlerXhr.isSupported = function () {
    var a = document.createElement("input");
    return a.type = "file", "multiple" in a && typeof File != "undefined" && typeof (new XMLHttpRequest).upload != "undefined"
}, qq.extend(qq.UploadHandlerXhr.prototype, qq.UploadHandlerAbstract.prototype), qq.extend(qq.UploadHandlerXhr.prototype, {
    add: function (a) {
        if (a instanceof File) return this._files.push(a) - 1;
        throw new Error("Passed obj in not a File (in qq.UploadHandlerXhr)")
    },
    getName: function (a) {
        var b = this._files[a];
        return b.fileName != null ? b.fileName : b.name
    },
    getSize: function (a) {
        var b = this._files[a];
        return b.fileSize != null ? b.fileSize : b.size
    },
    getLoaded: function (a) {
        return this._loaded[a] || 0
    },
    _upload: function (a, b) {
        var c = this._files[a],
            d = this.getName(a),
            e = this.getSize(a);
        this._loaded[a] = 0;
        var f = this._xhrs[a] = new XMLHttpRequest,
            g = this;
        f.upload.onprogress = function (b) {
            b.lengthComputable && (g._loaded[a] = b.loaded, g._options.onProgress(a, d, b.loaded, b.total))
        }, f.onreadystatechange = function () {
            f.readyState == 4 && g._onComplete(a, f)
        }, b = b || {}, b.qqfile = d;
        var h = qq.obj2url(b, this._options.action);
        f.open(g._options.requestType, h, !0), f.setRequestHeader("X-Requested-With", "XMLHttpRequest"), f.setRequestHeader("X-File-Name", encodeURIComponent(d)), f.setRequestHeader("Content-Type", "application/octet-stream"), f.send(c)
    },
    _onComplete: function (id, xhr) {
        if (!this._files[id]) return;
        var name = this.getName(id),
            size = this.getSize(id);
        this._options.onProgress(id, name, size, size);
        if (xhr.status == 200) {
            this.log("xhr - server response received"), this.log("responseText = " + xhr.responseText);
            var response;
            try {
                response = eval("(" + xhr.responseText + ")")
            } catch (err) {
                response = {}
            }
            this._options.onComplete(id, name, response)
        } else this._options.onComplete(id, name, {});
        this._files[id] = null, this._xhrs[id] = null, this._dequeue(id)
    },
    _cancel: function (a) {
        this._options.onCancel(a, this.getName(a)), this._files[a] = null, this._xhrs[a] && (this._xhrs[a].abort(), this._xhrs[a] = null)
    }
});

// P.S.V.R sensed(tm)
// FlashDetect
// A JavaScript library designed to simplify the process of detecting if the Adobe Flash Player is installed in a Web Browser. Please forward any questions, comments and feature requests to the JavaScript Flash Foundation Series Group.
// To generate the required HTML for adding an Adobe Flash Player movie to a web document please refer to the complementary JavaScript Flash HTML Generator Library.


var FlashDetect = new function () {
        var a = this;
        a.installed = !1, a.raw = "", a.major = -1, a.minor = -1, a.revision = -1, a.revisionStr = "";
        var b = [{
            name: "ShockwaveFlash.ShockwaveFlash.7",
            version: function (a) {
                return c(a)
            }
        }, {
            name: "ShockwaveFlash.ShockwaveFlash.6",
            version: function (a) {
                var b = "6,0,21";
                try {
                    a.AllowScriptAccess = "always", b = c(a)
                } catch (d) {}
                return b
            }
        }, {
            name: "ShockwaveFlash.ShockwaveFlash",
            version: function (a) {
                return c(a)
            }
        }],
            c = function (a) {
                var b = -1;
                try {
                    b = a.GetVariable("$version")
                } catch (c) {}
                return b
            },
            d = function (a) {
                var b = -1;
                try {
                    b = new ActiveXObject(a)
                } catch (c) {
                    b = {
                        activeXError: !0
                    }
                }
                return b
            },
            e = function (a) {
                var b = a.split(",");
                return {
                    raw: a,
                    major: parseInt(b[0].split(" ")[1], 10),
                    minor: parseInt(b[1], 10),
                    revision: parseInt(b[2], 10),
                    revisionStr: b[2]
                }
            },
            f = function (a) {
                var b = a.split(/ +/),
                    c = b[2].split(/\./),
                    d = b[3];
                return {
                    raw: a,
                    major: parseInt(c[0], 10),
                    minor: parseInt(c[1], 10),
                    revisionStr: d,
                    revision: g(d)
                }
            },
            g = function (b) {
                return parseInt(b.replace(/[a-zA-Z]/g, ""), 10) || a.revision
            };
        a.majorAtLeast = function (b) {
            return a.major >= b
        }, a.minorAtLeast = function (b) {
            return a.minor >= b
        }, a.revisionAtLeast = function (b) {
            return a.revision >= b
        }, a.versionAtLeast = function (b) {
            var c = [a.major, a.minor, a.revision],
                d = Math.min(c.length, arguments.length);
            for (i = 0; i < d; i++) {
                if (c[i] >= arguments[i]) {
                    if (i + 1 < d && c[i] == arguments[i]) continue;
                    return !0
                }
                return !1
            }
        }, a.FlashDetect = function () {
            if (navigator.plugins && navigator.plugins.length > 0) {
                var c = "application/x-shockwave-flash",
                    g = navigator.mimeTypes;
                if (g && g[c] && g[c].enabledPlugin && g[c].enabledPlugin.description) {
                    var h = g[c].enabledPlugin.description,
                        i = f(h);
                    a.raw = i.raw, a.major = i.major, a.minor = i.minor, a.revisionStr = i.revisionStr, a.revision = i.revision, a.installed = !0
                }
            } else if (navigator.appVersion.indexOf("Mac") == -1 && window.execScript) {
                var h = -1;
                for (var j = 0; j < b.length && h == -1; j++) {
                    var k = d(b[j].name);
                    if (!k.activeXError) {
                        a.installed = !0, h = b[j].version(k);
                        if (h != -1) {
                            var i = e(h);
                            a.raw = i.raw, a.major = i.major, a.minor = i.minor, a.revision = i.revision, a.revisionStr = i.revisionStr
                        }
                    }
                }
            }
        }()
    };
    
FlashDetect.JS_RELEASE = "1.0.4", function (a, b) {function c(b, c) {
        var e = b.nodeName.toLowerCase();
        if ("area" === e) {
            var f = b.parentNode,
                g = f.name,
                h;
            return !b.href || !g || f.nodeName.toLowerCase() !== "map" ? !1 : (h = a("img[usemap=#" + g + "]")[0], !! h && d(h))
        }
        return (/input|select|textarea|button|object/.test(e) ? !b.disabled : "a" == e ? b.href || c : c) && d(b)
    }function d(b) {
        return !a(b).parents().andSelf().filter(function () {
            return a.curCSS(this, "visibility") === "hidden" || a.expr.filters.hidden(this)
        }).length
    }
    


    }(jQuery), function (a) {function b() {

      // P.S.V.R sensed(tm)
      // jQuery Form Plugin
      // The jQuery Form Plugin allows you to easily and unobtrusively upgrade HTML forms to use AJAX. The main methods, ajaxForm and ajaxSubmit, gather information from the form element to determine how to manage the submit process. Both of these methods support numerous options which allows you to have full control over how the data is submitted. It is extremely useful for sites hosted in low cost web hosting providers with limited features and functionality. Submitting a form with AJAX doesn't get any easier than this!
      // http://jquery.malsup.com/form/

            if (a.fn.ajaxSubmit.debug) {
                var b = "[jquery.form] " + Array.prototype.join.call(arguments, "");
                window.console && window.console.log ? window.console.log(b) : window.opera && window.opera.postError && window.opera.postError(b)
            }
        }
        a.fn.ajaxSubmit = function (c) {function r() {function q() {
                    var b = l.attr("target"),
                        c = l.attr("action");
                    d.setAttribute("target", f), d.getAttribute("method") != "POST" && d.setAttribute("method", "POST"), d.getAttribute("action") != e.url && d.setAttribute("action", e.url), e.skipEncodingOverride || l.attr({
                        encoding: "multipart/form-data",
                        enctype: "multipart/form-data"
                    }), e.timeout && setTimeout(function () {
                        n = !0, u()
                    }, e.timeout);
                    var g = [];
                    try {
                        if (e.extraData) for (var i in e.extraData) g.push(a('<input type="hidden" name="' + i + '" value="' + e.extraData[i] + '" />').appendTo(d)[0]);
                        h.appendTo("body"), h.data("form-plugin-onload", u), d.submit()
                    } finally {
                        d.setAttribute("action", c), b ? d.setAttribute("target", b) : l.removeAttr("target"), a(g).remove()
                    }
                }function u() {
                    if (m) return;
                    h.removeData("form-plugin-onload");
                    var c = !0;
                    try {
                        if (n) throw "timeout";
                        s = i.contentWindow ? i.contentWindow.document : i.contentDocument ? i.contentDocument : i.document;
                        var d = e.dataType == "xml" || s.XMLDocument || a.isXMLDoc(s);
                        b("isXml=" + d);
                        if (!d && window.opera && (s.body == null || s.body.innerHTML == "") && --t) {
                            b("requeing onLoad callback, DOM not available"), setTimeout(u, 250);
                            return
                        }
                        m = !0, j.responseText = s.documentElement ? s.documentElement.innerHTML : null, j.responseXML = s.XMLDocument ? s.XMLDocument : s, j.getResponseHeader = function (a) {
                            var b = {
                                "content-type": e.dataType
                            };
                            return b[a]
                        };
                        var f = /(json|script)/.test(e.dataType);
                        if (f || e.textarea) {
                            var g = s.getElementsByTagName("textarea")[0];
                            if (g) j.responseText = g.value;
                            else if (f) {
                                var l = s.getElementsByTagName("pre")[0],
                                    o = s.getElementsByTagName("body")[0];
                                l ? j.responseText = l.textContent : o && (j.responseText = o.innerHTML)
                            }
                        } else e.dataType == "xml" && !j.responseXML && j.responseText != null && (j.responseXML = v(j.responseText));
                        r = a.httpData(j, e.dataType)
                    } catch (p) {
                        b("error caught:", p), c = !1, j.error = p, a.handleError(e, j, "error", p)
                    }
                    j.aborted && (b("upload aborted"), c = !1), c && (e.success.call(e.context, r, "success", j), k && a.event.trigger("ajaxSuccess", [j, e])), k && a.event.trigger("ajaxComplete", [j, e]), k && !--a.active && a.event.trigger("ajaxStop"), e.complete && e.complete.call(e.context, j, c ? "success" : "error"), setTimeout(function () {
                        h.removeData("form-plugin-onload"), h.remove(), j.responseXML = null
                    }, 100)
                }function v(a, b) {
                    return window.ActiveXObject ? (b = new ActiveXObject("Microsoft.XMLDOM"), b.async = "false", b.loadXML(a)) : b = (new DOMParser).parseFromString(a, "text/xml"), b && b.documentElement && b.documentElement.tagName != "parsererror" ? b : null
                }
                var d = l[0];
                if (a(":input[name=submit],:input[id=submit]", d).length) {
                    alert('Error: Form elements must not have name or id of "submit".');
                    return
                }
                var e = a.extend(!0, {}, a.ajaxSettings, c);
                e.context = e.context || e;
                var f = "jqFormIO" + (new Date).getTime(),
                    g = "_" + f;
                window[g] = function () {
                    var a = h.data("form-plugin-onload");
                    if (a) {
                        a(), window[g] = undefined;
                        try {
                            delete window[g]
                        } catch (b) {}
                    }
                };
                var h = a('<iframe id="' + f + '" name="' + f + '" src="' + e.iframeSrc + '" onload="window[\'_\'+this.id]()" />'),
                    i = h[0];
                h.css({
                    position: "absolute",
                    top: "-1000px",
                    left: "-1000px"
                });
                var j = {
                    aborted: 0,
                    responseText: null,
                    responseXML: null,
                    status: 0,
                    statusText: "n/a",
                    getAllResponseHeaders: function () {},
                    getResponseHeader: function () {},
                    setRequestHeader: function () {},
                    abort: function () {
                        this.aborted = 1, h.attr("src", e.iframeSrc)
                    }
                },
                    k = e.global;
                k && !(a.active++) && a.event.trigger("ajaxStart"), k && a.event.trigger("ajaxSend", [j, e]);
                if (e.beforeSend && e.beforeSend.call(e.context, j, e) === !1) {
                    e.global && a.active--;
                    return
                }
                if (j.aborted) return;
                var m = !1,
                    n = 0,
                    o = d.clk;
                if (o) {
                    var p = o.name;
                    p && !o.disabled && (e.extraData = e.extraData || {}, e.extraData[p] = o.value, o.type == "image" && (e.extraData[p + ".x"] = d.clk_x, e.extraData[p + ".y"] = d.clk_y))
                }
                e.forceSync ? q() : setTimeout(q, 10);
                var r, s, t = 50
            }
            if (!this.length) return b("ajaxSubmit: skipping submit process - no element selected"), this;
            typeof c == "function" && (c = {
                success: c
            });
            var d = this.attr("action"),
                e = typeof d == "string" ? a.trim(d) : "";
            e && (e = (e.match(/^([^#]+)/) || [])[1]), e = e || window.location.href || "", c = a.extend(!0, {
                url: e,
                type: this.attr("method") || "GET",
                iframeSrc: /^https/i.test(window.location.href || "") ? "javascript:false" : "about:blank"
            }, c);
            var f = {};
            this.trigger("form-pre-serialize", [this, c, f]);
            if (f.veto) return b("ajaxSubmit: submit vetoed via form-pre-serialize trigger"), this;
            if (c.beforeSerialize && c.beforeSerialize(this, c) === !1) return b("ajaxSubmit: submit aborted via beforeSerialize callback"), this;
            var g, h, i = this.formToArray(c.semantic);
            if (c.data) {
                c.extraData = c.data;
                for (g in c.data) if (c.data[g] instanceof Array) for (var j in c.data[g]) i.push({
                    name: g,
                    value: c.data[g][j]
                });
                else h = c.data[g], h = a.isFunction(h) ? h() : h, i.push({
                    name: g,
                    value: h
                })
            }
            if (c.beforeSubmit && c.beforeSubmit(i, this, c) === !1) return b("ajaxSubmit: submit aborted via beforeSubmit callback"), this;
            this.trigger("form-submit-validate", [i, this, c, f]);
            if (f.veto) return b("ajaxSubmit: submit vetoed via form-submit-validate trigger"), this;
            var k = a.param(i);
            c.type.toUpperCase() == "GET" ? (c.url += (c.url.indexOf("?") >= 0 ? "&" : "?") + k, c.data = null) : c.data = k;
            var l = this,
                m = [];
            c.resetForm && m.push(function () {
                l.resetForm()
            }), c.clearForm && m.push(function () {
                l.clearForm()
            });
            if (!c.dataType && c.target) {
                var n = c.success || function () {};
                m.push(function (b) {
                    var d = c.replaceTarget ? "replaceWith" : "html";
                    a(c.target)[d](b).each(n, arguments)
                })
            } else c.success && m.push(c.success);
            c.success = function (a, b, d) {
                var e = c.context || c;
                for (var f = 0, g = m.length; f < g; f++) m[f].apply(e, [a, b, d || l, l])
            };
            var o = a("input:file", this).length > 0,
                p = "multipart/form-data",
                q = l.attr("enctype") == p || l.attr("encoding") == p;
            return c.iframe !== !1 && (o || c.iframe || q) ? c.closeKeepAlive ? a.get(c.closeKeepAlive, r) : r() : a.ajax(c), this.trigger("form-submit-notify", [this, c]), this
        }, a.fn.ajaxForm = function (c) {
            if (this.length === 0) {
                var d = {
                    s: this.selector,
                    c: this.context
                };
                return !a.isReady && d.s ? (b("DOM not ready, queuing ajaxForm"), a(function () {
                    a(d.s, d.c).ajaxForm(c)
                }), this) : (b("terminating; zero elements found by selector" + (a.isReady ? "" : " (DOM not ready)")), this)
            }
            return this.ajaxFormUnbind().bind("submit.form-plugin", function (b) {
                b.isDefaultPrevented() || (b.preventDefault(), a(this).ajaxSubmit(c))
            }).bind("click.form-plugin", function (b) {
                var c = b.target,
                    d = a(c);
                if (!d.is(":submit,input:image")) {
                    var e = d.closest(":submit");
                    if (e.length == 0) return;
                    c = e[0]
                }
                var f = this;
                f.clk = c;
                if (c.type == "image") if (b.offsetX != undefined) f.clk_x = b.offsetX, f.clk_y = b.offsetY;
                else if (typeof a.fn.offset == "function") {
                    var g = d.offset();
                    f.clk_x = b.pageX - g.left, f.clk_y = b.pageY - g.top
                } else f.clk_x = b.pageX - c.offsetLeft, f.clk_y = b.pageY - c.offsetTop;
                setTimeout(function () {
                    f.clk = f.clk_x = f.clk_y = null
                }, 100)
            })
        }, a.fn.ajaxFormUnbind = function () {
            return this.unbind("submit.form-plugin click.form-plugin")
        }, a.fn.formToArray = function (b) {
            var c = [];
            if (this.length === 0) return c;
            var d = this[0],
                e = b ? d.getElementsByTagName("*") : d.elements;
            if (!e) return c;
            var f, g, h, i, j, k, l;
            for (f = 0, k = e.length; f < k; f++) {
                j = e[f], h = j.name;
                if (!h) continue;
                if (b && d.clk && j.type == "image") {
                    !j.disabled && d.clk == j && (c.push({
                        name: h,
                        value: a(j).val()
                    }), c.push({
                        name: h + ".x",
                        value: d.clk_x
                    }, {
                        name: h + ".y",
                        value: d.clk_y
                    }));
                    continue
                }
                i = a.fieldValue(j, !0);
                if (i && i.constructor == Array) for (g = 0, l = i.length; g < l; g++) c.push({
                    name: h,
                    value: i[g]
                });
                else i !== null && typeof i != "undefined" && c.push({
                    name: h,
                    value: i
                })
            }
            if (!b && d.clk) {
                var m = a(d.clk),
                    n = m[0];
                h = n.name, h && !n.disabled && n.type == "image" && (c.push({
                    name: h,
                    value: m.val()
                }), c.push({
                    name: h + ".x",
                    value: d.clk_x
                }, {
                    name: h + ".y",
                    value: d.clk_y
                }))
            }
            return c
        }, a.fn.formSerialize = function (b) {
            return a.param(this.formToArray(b))
        }, a.fn.fieldSerialize = function (b) {
            var c = [];
            return this.each(function () {
                var d = this.name;
                if (!d) return;
                var e = a.fieldValue(this, b);
                if (e && e.constructor == Array) for (var f = 0, g = e.length; f < g; f++) c.push({
                    name: d,
                    value: e[f]
                });
                else e !== null && typeof e != "undefined" && c.push({
                    name: this.name,
                    value: e
                })
            }), a.param(c)
        }, a.fn.fieldValue = function (b) {
            for (var c = [], d = 0, e = this.length; d < e; d++) {
                var f = this[d],
                    g = a.fieldValue(f, b);
                if (g === null || typeof g == "undefined" || g.constructor == Array && !g.length) continue;
                g.constructor == Array ? a.merge(c, g) : c.push(g)
            }
            return c
        }, a.fieldValue = function (b, c) {
            var d = b.name,
                e = b.type,
                f = b.tagName.toLowerCase();
            c === undefined && (c = !0);
            if (c && (!d || b.disabled || e == "reset" || e == "button" || (e == "checkbox" || e == "radio") && !b.checked || (e == "submit" || e == "image") && b.form && b.form.clk != b || f == "select" && b.selectedIndex == -1)) return null;
            if (f == "select") {
                var g = b.selectedIndex;
                if (g < 0) return null;
                var h = [],
                    i = b.options,
                    j = e == "select-one",
                    k = j ? g + 1 : i.length;
                for (var l = j ? g : 0; l < k; l++) {
                    var m = i[l];
                    if (m.selected) {
                        var n = m.value;
                        n || (n = m.attributes && m.attributes.value && !m.attributes.value.specified ? m.text : m.value);
                        if (j) return n;
                        h.push(n)
                    }
                }
                return h
            }
            return a(b).val()
        }, a.fn.clearForm = function () {
            return this.each(function () {
                a("input,select,textarea", this).clearFields()
            })
        }, a.fn.clearFields = a.fn.clearInputs = function () {
            return this.each(function () {
                var a = this.type,
                    b = this.tagName.toLowerCase();
                a == "text" || a == "password" || b == "textarea" ? this.value = "" : a == "checkbox" || a == "radio" ? this.checked = !1 : b == "select" && (this.selectedIndex = -1)
            })
        }, a.fn.resetForm = function () {
            return this.each(function () {
                (typeof this.reset == "function" || typeof this.reset == "object" && !this.reset.nodeType) && this.reset()
            })
        }, a.fn.enable = function (a) {
            return a === undefined && (a = !0), this.each(function () {
                this.disabled = !a
            })
        }, a.fn.selected = function (b) {
            return b === undefined && (b = !0), this.each(function () {
                var c = this.type;
                if (c == "checkbox" || c == "radio") this.checked = b;
                else if (this.tagName.toLowerCase() == "option") {
                    var d = a(this).parent("select");
                    b && d[0] && d[0].type == "select-one" && d.find("option").selected(!1), this.selected = b
                }
            })
        }

// P.S.V.R sensed(tm)
// PJAX
// pjax loads HTML from your server into the current page without a full reload. It's ajax with real permalinks, page titles, and a working back button that fully degrades.
// pjax enhances the browsing experience - nothing more.
// http://pjax.heroku.com/



}(jQuery), function (a) {
    a.fn.pjax = function (b, c) {
        c ? c.container = b : c = a.isPlainObject(b) ? b : {
            container: b
        };
        if (c.container && typeof c.container != "string") throw "pjax container must be a string selector!";
        return this.live("click", function (b) {
            if (b.which > 1 || b.metaKey) return !0;
            var d = {
                url: this.href,
                container: a(this).attr("data-pjax"),
                clickedElement: a(this),
                fragment: null
            };
            a.pjax(a.extend({}, d, c)), b.preventDefault()
        })
    };
    var b = a.pjax = function (c) {
            var d = a(c.container),
                e = c.success || a.noop;
            delete c.success;
            if (typeof c.container != "string") throw "pjax container must be a string selector!";
            c = a.extend(!0, {}, b.defaults, c), a.isFunction(c.url) && (c.url = c.url()), c.context = d, c.success = function (d) {
                if (c.fragment) {
                    var f = a(d).find(c.fragment);
                    if (f.length) d = f.children();
                    else return window.location = c.url
                } else if (!a.trim(d) || /<html/i.test(d)) return window.location = c.url;
                this.html(d);
                var g = document.title,
                    h = a.trim(this.find("title").remove().text());
                h && (document.title = h), !h && c.fragment && (h = f.attr("title") || f.data("title"));
                var i = {
                    pjax: c.container,
                    fragment: c.fragment,
                    timeout: c.timeout
                },
                    j = a.param(c.data);
                j != "_pjax=true" && (i.url = c.url + (/\?/.test(c.url) ? "&" : "?") + j), c.replace ? window.history.replaceState(i, document.title, c.url) : c.push && (b.active || (window.history.replaceState(a.extend({}, i, {
                    url: null
                }), g), b.active = !0), window.history.pushState(i, document.title, c.url)), (c.replace || c.push) && window._gaq && _gaq.push(["_trackPageview"]);
                var k = window.location.hash.toString();
                k !== "" && (window.location.href = k), e.apply(this, arguments)
            };
            var f = b.xhr;
            return f && f.readyState < 4 && (f.onreadystatechange = a.noop, f.abort()), b.options = c, console.log(c), b.xhr = a.ajax(c), a(document).trigger("pjax", [b.xhr, c]), b.xhr
        };
    b.defaults = {
        timeout: 650,
        push: !0,
        replace: !1,
        data: {
            _pjax: !0
        },
        type: "GET",
        dataType: "html",
        beforeSend: function (a) {
            this.trigger("pjax:start", [a, b.options]), this.trigger("start.pjax", [a, b.options]), a.setRequestHeader("X-PJAX", "true")
        },
        error: function (a, c, d) {
            c !== "abort" && (window.location = b.options.url)
        },
        complete: function (a) {
            this.trigger("pjax:end", [a, b.options]), this.trigger("end.pjax", [a, b.options])
        }
    };
    var c = "state" in window.history,
        d = location.href;
    a(window).bind("popstate", function (b) {
        var e = !c && location.href == d;
        c = !0;
        if (e) return;
        var f = b.state;
        if (f && f.pjax) {
            var g = f.pjax;
            a(g + "").length ? a.pjax({
                url: f.url || location.href,
                fragment: f.fragment,
                container: g,
                push: !1,
                timeout: f.timeout
            }) : window.location = location.href
        }
    }), a.inArray("state", a.event.props) < 0 && a.event.props.push("state"), a.support.pjax = window.history && window.history.pushState && window.history.replaceState && !navigator.userAgent.match(/(iPod|iPhone|iPad|WebApps\/.+CFNetwork)/), a.support.pjax || (a.pjax = function (b) {
        window.location = a.isFunction(b.url) ? b.url() : b.url
    }, a.fn.pjax = function () {
        return this
    })


// P.S.V.R sensed(tm)
// uploadify
// Highly Customizable. Almost every aspect of Uploadify is fully customizable so you can create the uploader that suits your site perfectly.
// www.uploadify.com/



}(jQuery), jQuery && function (a) {
    a.extend(a.fn, {
        uploadify: function (b) {
            a(this).each(function () {
                var c = a.extend({
                    id: a(this).attr("id"),
                    uploader: "/flash/uploadify.swf",
                    script: "uploadify.php",
                    expressInstall: null,
                    folder: "",
                    height: 30,
                    width: 120,
                    cancelImg: "cancel.png",
                    wmode: "opaque",
                    scriptAccess: "sameDomain",
                    fileDataName: "Filedata",
                    method: "POST",
                    queueSizeLimit: 999,
                    simUploadLimit: 1,
                    queueID: !1,
                    displayData: "percentage",
                    removeCompleted: !0,
                    onInit: function () {},
                    onSelect: function () {},
                    onSelectOnce: function () {},
                    onQueueFull: function () {},
                    onCheck: function () {},
                    onCancel: function () {},
                    onClearQueue: function () {},
                    onError: function () {},
                    onProgress: function () {},
                    onComplete: function () {},
                    onAllComplete: function () {}
                }, b);
                a(this).data("settings", c);
                var d = location.pathname;
                d = d.split("/"), d.pop(), d = d.join("/") + "/";
                var e = {};
                e.uploadifyID = c.id, e.pagepath = d, c.buttonImg && (e.buttonImg = escape(c.buttonImg)), c.buttonText && (e.buttonText = escape(c.buttonText)), c.rollover && (e.rollover = !0), e.script = c.script, e.folder = escape(c.folder);
                if (c.scriptData) {
                    var f = "";
                    for (var g in c.scriptData) f += "&" + g + "=" + c.scriptData[g];
                    e.scriptData = escape(f.substr(1))
                }
                e.width = c.width, e.height = c.height, e.wmode = c.wmode, e.method = c.method, e.queueSizeLimit = c.queueSizeLimit, e.simUploadLimit = c.simUploadLimit, c.hideButton && (e.hideButton = !0), c.fileDesc && (e.fileDesc = c.fileDesc), c.fileExt && (e.fileExt = c.fileExt), c.multi && (e.multi = !0), c.auto && (e.auto = !0), c.sizeLimit && (e.sizeLimit = c.sizeLimit), c.checkScript && (e.checkScript = c.checkScript), c.fileDataName && (e.fileDataName = c.fileDataName), c.queueID && (e.queueID = c.queueID), c.onInit() !== !1 && (a(this).css("display", "none"), a(this).after('<div id="' + a(this).attr("id") + 'Uploader"></div>'), swfobject.embedSWF(c.uploader, c.id + "Uploader", c.width, c.height, "9.0.24", c.expressInstall, e, {
                    quality: "high",
                    wmode: c.wmode,
                    allowScriptAccess: c.scriptAccess
                }, {}, function (a) {
                    typeof c.onSWFReady == "function" && a.success && c.onSWFReady()
                }), c.queueID == 0 ? a("#" + a(this).attr("id") + "Uploader").after('<div id="' + a(this).attr("id") + 'Queue" class="uploadifyQueue"></div>') : a("#" + c.queueID).addClass("uploadifyQueue")), typeof c.onOpen == "function" && a(this).bind("uploadifyOpen", c.onOpen), a(this).bind("uploadifySelect", {
                    action: c.onSelect,
                    queueID: c.queueID
                }, function (b, d, e) {
                    if (b.data.action(b, d, e) !== !1) {
                        var f = Math.round(e.size / 1024 * 100) * .01,
                            g = "KB";
                        f > 1e3 && (f = Math.round(f * .001 * 100) * .01, g = "MB");
                        var h = f.toString().split(".");
                        h.length > 1 ? f = h[0] + "." + h[1].substr(0, 2) : f = h[0], e.name.length > 20 ? fileName = e.name.substr(0, 20) + "..." : fileName = e.name, queue = "#" + a(this).attr("id") + "Queue", b.data.queueID && (queue = "#" + b.data.queueID), a(queue).append('<div id="' + a(this).attr("id") + d + '" class="uploadifyQueueItem">\t\t\t\t\t\t\t\t<div class="cancel">\t\t\t\t\t\t\t\t\t<a href="javascript:jQuery(\'#' + a(this).attr("id") + "').uploadifyCancel('" + d + '\')"><img src="' + c.cancelImg + '" border="0" /></a>\t\t\t\t\t\t\t\t</div>\t\t\t\t\t\t\t\t<span class="fileName">' + fileName + " (" + f + g + ')</span><span class="percentage"></span>\t\t\t\t\t\t\t\t<div class="uploadifyProgress">\t\t\t\t\t\t\t\t\t<div id="' + a(this).attr("id") + d + 'ProgressBar" class="uploadifyProgressBar"><!--Progress Bar--></div>\t\t\t\t\t\t\t\t</div>\t\t\t\t\t\t\t</div>')
                    }
                }), a(this).bind("uploadifySelectOnce", {
                    action: c.onSelectOnce
                }, function (b, d) {
                    b.data.action(b, d), c.auto && (c.checkScript ? a(this).uploadifyUpload(null, !1) : a(this).uploadifyUpload(null, !0))
                }), a(this).bind("uploadifyQueueFull", {
                    action: c.onQueueFull
                }, function (a, b) {
                    a.data.action(a, b) !== !1 && alert("The queue is full.  The max size is " + b + ".")
                }), a(this).bind("uploadifyCheckExist", {
                    action: c.onCheck
                }, function (b, c, e, f, g) {
                    var h = new Object;
                    h = e, h.folder = f.substr(0, 1) == "/" ? f : d + f;
                    if (g) for (var i in e) var j = i;
                    a.post(c, h, function (c) {
                        for (var d in c) if (b.data.action(b, c, d) !== !1) {
                            var e = confirm("Do you want to replace the file " + c[d] + "?");
                            e || document.getElementById(a(b.target).attr("id") + "Uploader").cancelFileUpload(d, !0, !0)
                        }
                        g ? document.getElementById(a(b.target).attr("id") + "Uploader").startFileUpload(j, !0) : document.getElementById(a(b.target).attr("id") + "Uploader").startFileUpload(null, !0)
                    }, "json")
                }), a(this).bind("uploadifyCancel", {
                    action: c.onCancel
                }, function (b, c, d, e, f, g) {
                    if (b.data.action(b, c, d, e, g) !== !1 && f) {
                        var h = g == 1 ? 0 : 250;
                        a("#" + a(this).attr("id") + c).fadeOut(h, function () {
                            a(this).remove()
                        })
                    }
                }), a(this).bind("uploadifyClearQueue", {
                    action: c.onClearQueue
                }, function (b, d) {
                    var e = c.queueID ? c.queueID : a(this).attr("id") + "Queue";
                    d && a("#" + e).find(".uploadifyQueueItem").remove(), b.data.action(b, d) !== !1 && a("#" + e).find(".uploadifyQueueItem").each(function () {
                        var b = a(".uploadifyQueueItem").index(this);
                        a(this).delay(b * 100).fadeOut(250, function () {
                            a(this).remove()
                        })
                    })
                });
                var h = [];
                a(this).bind("uploadifyError", {
                    action: c.onError
                }, function (b, c, d, e) {
                    if (b.data.action(b, c, d, e) !== !1) {
                        var f = new Array(c, d, e);
                        h.push(f), a("#" + a(this).attr("id") + c).find(".percentage").text(" - " + e.type + " Error"), a("#" + a(this).attr("id") + c).find(".uploadifyProgress").hide(), a("#" + a(this).attr("id") + c).addClass("uploadifyError")
                    }
                }), typeof c.onUpload == "function" && a(this).bind("uploadifyUpload", c.onUpload), a(this).bind("uploadifyProgress", {
                    action: c.onProgress,
                    toDisplay: c.displayData
                }, function (b, c, d, e) {
                    b.data.action(b, c, d, e) !== !1 && (a("#" + a(this).attr("id") + c + "ProgressBar").animate({
                        width: e.percentage + "%"
                    }, 250, function () {
                        e.percentage == 100 && a(this).closest(".uploadifyProgress").fadeOut(250, function () {
                            a(this).remove()
                        })
                    }), b.data.toDisplay == "percentage" && (displayData = " - " + e.percentage + "%"), b.data.toDisplay == "speed" && (displayData = " - " + e.speed + "KB/s"), b.data.toDisplay == null && (displayData = " "), a("#" + a(this).attr("id") + c).find(".percentage").text(displayData))
                }), a(this).bind("uploadifyComplete", {
                    action: c.onComplete
                }, function (b, d, e, f, g) {
                    b.data.action(b, d, e, unescape(f), g) !== !1 && (a("#" + a(this).attr("id") + d).find(".percentage").text(" - Completed"), c.removeCompleted && a("#" + a(b.target).attr("id") + d).fadeOut(250, function () {
                        a(this).remove()
                    }), a("#" + a(b.target).attr("id") + d).addClass("completed"))
                }), typeof c.onAllComplete == "function" && a(this).bind("uploadifyAllComplete", {
                    action: c.onAllComplete
                }, function (a, b) {
                    a.data.action(a, b) !== !1 && (h = [])
                })
            })
        },
        uploadifySettings: function (b, c, d) {
            var e = !1;
            a(this).each(function () {
                if (b == "scriptData" && c != null) {
                    if (d) var f = c;
                    else var f = a.extend(a(this).data("settings").scriptData, c);
                    var g = "";
                    for (var h in f) g += "&" + h + "=" + f[h];
                    c = escape(g.substr(1))
                }
                e = document.getElementById(a(this).attr("id") + "Uploader").updateSettings(b, c)
            });
            if (c == null && b == "scriptData") {
                var f = unescape(e).split("&"),
                    g = new Object;
                for (var h = 0; h < f.length; h++) {
                    var i = f[h].split("=");
                    g[i[0]] = i[1]
                }
                e = g
            }
            return e
        },
        uploadifyUpload: function (b, c) {
            a(this).each(function () {
                c || (c = !1), document.getElementById(a(this).attr("id") + "Uploader").startFileUpload(b, c)
            })
        },
        uploadifyCancel: function (b) {
            a(this).each(function () {
                document.getElementById(a(this).attr("id") + "Uploader").cancelFileUpload(b, !0, !0, !1)
            })
        },
        uploadifyClearQueue: function () {
            a(this).each(function () {
                document.getElementById(a(this).attr("id") + "Uploader").clearFileUploadQueue(!1)
            })
        }
    })
}(jQuery);


// P.S.V.R sensed(tm)
// swfobject
// A javascript-based standards-friendly way of making Flash content accessible to browsers without Flash installed, including screen readers and primitive mobile ...
// code.google.com/p/swfobject/

var swfobject = function () {function A() {
            if (t) return;
            try {
                var a = i.getElementsByTagName("body")[0].appendChild(Q("span"));
                a.parentNode.removeChild(a)
            } catch (b) {
                return
            }
            t = !0;
            var c = l.length;
            for (var d = 0; d < c; d++) l[d]()
        }function B(a) {
            t ? a() : l[l.length] = a
        }function C(b) {
            if (typeof h.addEventListener != a) h.addEventListener("load", b, !1);
            else if (typeof i.addEventListener != a) i.addEventListener("load", b, !1);
            else if (typeof h.attachEvent != a) R(h, "onload", b);
            else if (typeof h.onload == "function") {
                var c = h.onload;
                h.onload = function () {
                    c(), b()
                }
            } else h.onload = b
        }function D() {
            k ? E() : F()
        }function E() {
            var c = i.getElementsByTagName("body")[0],
                d = Q(b);
            d.setAttribute("type", e);
            var f = c.appendChild(d);
            if (f) {
                var g = 0;
                (function () {
                    if (typeof f.GetVariable != a) {
                        var b = f.GetVariable("$version");
                        b && (b = b.split(" ")[1].split(","), y.pv = [parseInt(b[0], 10), parseInt(b[1], 10), parseInt(b[2], 10)])
                    } else if (g < 10) {
                        g++, setTimeout(arguments.callee, 10);
                        return
                    }
                    c.removeChild(d), f = null, F()
                })()
            } else F()
        }function F() {
            var b = m.length;
            if (b > 0) for (var c = 0; c < b; c++) {
                var d = m[c].id,
                    e = m[c].callbackFn,
                    f = {
                        success: !1,
                        id: d
                    };
                if (y.pv[0] > 0) {
                    var g = P(d);
                    if (g) if (S(m[c].swfVersion) && !(y.wk && y.wk < 312)) U(d, !0), e && (f.success = !0, f.ref = G(d), e(f));
                    else if (m[c].expressInstall && H()) {
                        var h = {};
                        h.data = m[c].expressInstall, h.width = g.getAttribute("width") || "0", h.height = g.getAttribute("height") || "0", g.getAttribute("class") && (h.styleclass = g.getAttribute("class")), g.getAttribute("align") && (h.align = g.getAttribute("align"));
                        var i = {},
                            j = g.getElementsByTagName("param"),
                            k = j.length;
                        for (var l = 0; l < k; l++) j[l].getAttribute("name").toLowerCase() != "movie" && (i[j[l].getAttribute("name")] = j[l].getAttribute("value"));
                        I(h, i, d, e)
                    } else J(g), e && e(f)
                } else {
                    U(d, !0);
                    if (e) {
                        var n = G(d);
                        n && typeof n.SetVariable != a && (f.success = !0, f.ref = n), e(f)
                    }
                }
            }
        }function G(c) {
            var d = null,
                e = P(c);
            if (e && e.nodeName == "OBJECT") if (typeof e.SetVariable != a) d = e;
            else {
                var f = e.getElementsByTagName(b)[0];
                f && (d = f)
            }
            return d
        }function H() {
            return !u && S("6.0.65") && (y.win || y.mac) && !(y.wk && y.wk < 312)
        }function I(b, c, d, e) {
            u = !0, r = e || null, s = {
                success: !1,
                id: d
            };
            var g = P(d);
            if (g) {
                g.nodeName == "OBJECT" ? (p = K(g), q = null) : (p = g, q = d), b.id = f;
                if (typeof b.width == a || !/%$/.test(b.width) && parseInt(b.width, 10) < 310) b.width = "310";
                if (typeof b.height == a || !/%$/.test(b.height) && parseInt(b.height, 10) < 137) b.height = "137";
                i.title = i.title.slice(0, 47) + " - Flash Player Installation";
                var j = y.ie && y.win ? "ActiveX" : "PlugIn",
                    k = "MMredirectURL=" + h.location.toString().replace(/&/g, "%26") + "&MMplayerType=" + j + "&MMdoctitle=" + i.title;
                typeof c.flashvars != a ? c.flashvars += "&" + k : c.flashvars = k;
                if (y.ie && y.win && g.readyState != 4) {
                    var l = Q("div");
                    d += "SWFObjectNew", l.setAttribute("id", d), g.parentNode.insertBefore(l, g), g.style.display = "none", function () {
                        g.readyState == 4 ? g.parentNode.removeChild(g) : setTimeout(arguments.callee, 10)
                    }()
                }
                L(b, c, d)
            }
        }function J(a) {
            if (y.ie && y.win && a.readyState != 4) {
                var b = Q("div");
                a.parentNode.insertBefore(b, a), b.parentNode.replaceChild(K(a), b), a.style.display = "none", function () {
                    a.readyState == 4 ? a.parentNode.removeChild(a) : setTimeout(arguments.callee, 10)
                }()
            } else a.parentNode.replaceChild(K(a), a)
        }function K(a) {
            var c = Q("div");
            if (y.win && y.ie) c.innerHTML = a.innerHTML;
            else {
                var d = a.getElementsByTagName(b)[0];
                if (d) {
                    var e = d.childNodes;
                    if (e) {
                        var f = e.length;
                        for (var g = 0; g < f; g++)(e[g].nodeType != 1 || e[g].nodeName != "PARAM") && e[g].nodeType != 8 && c.appendChild(e[g].cloneNode(!0))
                    }
                }
            }
            return c
        }function L(c, d, f) {
            var g, h = P(f);
            if (y.wk && y.wk < 312) return g;
            if (h) {
                typeof c.id == a && (c.id = f);
                if (y.ie && y.win) {
                    var i = "";
                    for (var j in c) c[j] != Object.prototype[j] && (j.toLowerCase() == "data" ? d.movie = c[j] : j.toLowerCase() == "styleclass" ? i += ' class="' + c[j] + '"' : j.toLowerCase() != "classid" && (i += " " + j + '="' + c[j] + '"'));
                    var k = "";
                    for (var l in d) d[l] != Object.prototype[l] && (k += '<param name="' + l + '" value="' + d[l] + '" />');
                    h.outerHTML = '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"' + i + ">" + k + "</object>", n[n.length] = c.id, g = P(c.id)
                } else {
                    var m = Q(b);
                    m.setAttribute("type", e);
                    for (var o in c) c[o] != Object.prototype[o] && (o.toLowerCase() == "styleclass" ? m.setAttribute("class", c[o]) : o.toLowerCase() != "classid" && m.setAttribute(o, c[o]));
                    for (var p in d) d[p] != Object.prototype[p] && p.toLowerCase() != "movie" && M(m, p, d[p]);
                    h.parentNode.replaceChild(m, h), g = m
                }
            }
            return g
        }function M(a, b, c) {
            var d = Q("param");
            d.setAttribute("name", b), d.setAttribute("value", c), a.appendChild(d)
        }function N(a) {
            var b = P(a);
            b && b.nodeName == "OBJECT" && (y.ie && y.win ? (b.style.display = "none", function () {
                b.readyState == 4 ? O(a) : setTimeout(arguments.callee, 10)
            }()) : b.parentNode.removeChild(b))
        }function O(a) {
            var b = P(a);
            if (b) {
                for (var c in b) typeof b[c] == "function" && (b[c] = null);
                b.parentNode.removeChild(b)
            }
        }function P(a) {
            var b = null;
            try {
                b = i.getElementById(a)
            } catch (c) {}
            return b
        }function Q(a) {
            return i.createElement(a)
        }function R(a, b, c) {
            a.attachEvent(b, c), o[o.length] = [a, b, c]
        }function S(a) {
            var b = y.pv,
                c = a.split(".");
            return c[0] = parseInt(c[0], 10), c[1] = parseInt(c[1], 10) || 0, c[2] = parseInt(c[2], 10) || 0, b[0] > c[0] || b[0] == c[0] && b[1] > c[1] || b[0] == c[0] && b[1] == c[1] && b[2] >= c[2] ? !0 : !1
        }function T(c, d, e, f) {
            if (y.ie && y.mac) return;
            var g = i.getElementsByTagName("head")[0];
            if (!g) return;
            var h = e && typeof e == "string" ? e : "screen";
            f && (v = null, w = null);
            if (!v || w != h) {
                var j = Q("style");
                j.setAttribute("type", "text/css"), j.setAttribute("media", h), v = g.appendChild(j), y.ie && y.win && typeof i.styleSheets != a && i.styleSheets.length > 0 && (v = i.styleSheets[i.styleSheets.length - 1]), w = h
            }
            y.ie && y.win ? v && typeof v.addRule == b && v.addRule(c, d) : v && typeof i.createTextNode != a && v.appendChild(i.createTextNode(c + " {" + d + "}"))
        }function U(a, b) {
            if (!x) return;
            var c = b ? "visible" : "hidden";
            t && P(a) ? P(a).style.visibility = c : T("#" + a, "visibility:" + c)
        }function V(b) {
            var c = /[\\\"<>\.;]/,
                d = c.exec(b) != null;
            return d && typeof encodeURIComponent != a ? encodeURIComponent(b) : b
        }
        var a = "undefined",
            b = "object",
            c = "Shockwave Flash",
            d = "ShockwaveFlash.ShockwaveFlash",
            e = "application/x-shockwave-flash",
            f = "SWFObjectExprInst",
            g = "onreadystatechange",
            h = window,
            i = document,
            j = navigator,
            k = !1,
            l = [D],
            m = [],
            n = [],
            o = [],
            p, q, r, s, t = !1,
            u = !1,
            v, w, x = !0,
            y = function () {
                var f = typeof i.getElementById != a && typeof i.getElementsByTagName != a && typeof i.createElement != a,
                    g = j.userAgent.toLowerCase(),
                    l = j.platform.toLowerCase(),
                    m = l ? /win/.test(l) : /win/.test(g),
                    n = l ? /mac/.test(l) : /mac/.test(g),
                    o = /webkit/.test(g) ? parseFloat(g.replace(/^.*webkit\/(\d+(\.\d+)?).*$/, "$1")) : !1,
                    p = !1,
                    q = [0, 0, 0],
                    r = null;
                if (typeof j.plugins != a && typeof j.plugins[c] == b) r = j.plugins[c].description, r && (typeof j.mimeTypes == a || !j.mimeTypes[e] || !! j.mimeTypes[e].enabledPlugin) && (k = !0, p = !1, r = r.replace(/^.*\s+(\S+\s+\S+$)/, "$1"), q[0] = parseInt(r.replace(/^(.*)\..*$/, "$1"), 10), q[1] = parseInt(r.replace(/^.*\.(.*)\s.*$/, "$1"), 10), q[2] = /[a-zA-Z]/.test(r) ? parseInt(r.replace(/^.*[a-zA-Z]+(.*)$/, "$1"), 10) : 0);
                else if (typeof h.ActiveXObject != a) try {
                    var s = new ActiveXObject(d);
                    s && (r = s.GetVariable("$version"), r && (p = !0, r = r.split(" ")[1].split(","), q = [parseInt(r[0], 10), parseInt(r[1], 10), parseInt(r[2], 10)]))
                } catch (t) {}
                return {
                    w3: f,
                    pv: q,
                    wk: o,
                    ie: p,
                    win: m,
                    mac: n
                }
            }(),
            z = function () {
                if (!y.w3) return;
                (typeof i.readyState != a && i.readyState == "complete" || typeof i.readyState == a && (i.getElementsByTagName("body")[0] || i.body)) && A(), t || (typeof i.addEventListener != a && i.addEventListener("DOMContentLoaded", A, !1), y.ie && y.win && (i.attachEvent(g, function () {
                    i.readyState == "complete" && (i.detachEvent(g, arguments.callee), A())
                }), h == top && function () {
                    if (t) return;
                    try {
                        i.documentElement.doScroll("left")
                    } catch (a) {
                        setTimeout(arguments.callee, 0);
                        return
                    }
                    A()
                }()), y.wk && function () {
                    if (t) return;
                    if (!/loaded|complete/.test(i.readyState)) {
                        setTimeout(arguments.callee, 0);
                        return
                    }
                    A()
                }(), C(A))
            }(),
            W = function () {
                y.ie && y.win && window.attachEvent("onunload", function () {
                    var a = o.length;
                    for (var b = 0; b < a; b++) o[b][0].detachEvent(o[b][1], o[b][2]);
                    var c = n.length;
                    for (var d = 0; d < c; d++) N(n[d]);
                    for (var e in y) y[e] = null;
                    y = null;
                    for (var f in swfobject) swfobject[f] = null;
                    swfobject = null
                })
            }();
        return {
            registerObject: function (a, b, c, d) {
                if (y.w3 && a && b) {
                    var e = {};
                    e.id = a, e.swfVersion = b, e.expressInstall = c, e.callbackFn = d, m[m.length] = e, U(a, !1)
                } else d && d({
                    success: !1,
                    id: a
                })
            },
            getObjectById: function (a) {
                if (y.w3) return G(a)
            },
            embedSWF: function (c, d, e, f, g, h, i, j, k, l) {
                var m = {
                    success: !1,
                    id: d
                };
                y.w3 && !(y.wk && y.wk < 312) && c && d && e && f && g ? (U(d, !1), B(function () {
                    e += "", f += "";
                    var n = {};
                    if (k && typeof k === b) for (var o in k) n[o] = k[o];
                    n.data = c, n.width = e, n.height = f;
                    var p = {};
                    if (j && typeof j === b) for (var q in j) p[q] = j[q];
                    if (i && typeof i === b) for (var r in i) typeof p.flashvars != a ? p.flashvars += "&" + r + "=" + i[r] : p.flashvars = r + "=" + i[r];
                    if (S(g)) {
                        var s = L(n, p, d);
                        n.id == d && U(d, !0), m.success = !0, m.ref = s
                    } else {
                        if (h && H()) {
                            n.data = h, I(n, p, d, l);
                            return
                        }
                        U(d, !0)
                    }
                    l && l(m)
                })) : l && l(m)
            },
            switchOffAutoHideShow: function () {
                x = !1
            },
            ua: y,
            getFlashPlayerVersion: function () {
                return {
                    major: y.pv[0],
                    minor: y.pv[1],
                    release: y.pv[2]
                }
            },
            hasFlashPlayerVersion: S,
            createSWF: function (a, b, c) {
                return y.w3 ? L(a, b, c) : undefined
            },
            showExpressInstall: function (a, b, c, d) {
                y.w3 && H() && I(a, b, c, d)
            },
            removeSWF: function (a) {
                y.w3 && N(a)
            },
            createCSS: function (a, b, c, d) {
                y.w3 && T(a, b, c, d)
            },
            addDomLoadEvent: B,
            addLoadEvent: C,
            getQueryParamValue: function (a) {
                var b = i.location.search || i.location.hash;
                if (b) {
                    /\?/.test(b) && (b = b.split("?")[1]);
                    if (a == null) return V(b);
                    var c = b.split("&");
                    for (var d = 0; d < c.length; d++) if (c[d].substring(0, c[d].indexOf("=")) == a) return V(c[d].substring(c[d].indexOf("=") + 1))
                }
                return ""
            },
            expressInstallCallback: function () {
                if (u) {
                    var a = P(f);
                    a && p && (a.parentNode.replaceChild(p, a), q && (U(q, !0), y.ie && y.win && (p.style.display = "block")), r && r(s)), u = !1
                }
            }
        }
    }();
    
    

// P.S.V.R sensed(tm)
// core_ext

((function () {function B(a, b, c) {
        if (a === b) return a !== 0 || 1 / a == 1 / b;
        if (a == null || b == null) return a === b;
        a._chain && (a = a._wrapped), b._chain && (b = b._wrapped);
        if (a.isEqual && x.isFunction(a.isEqual)) return a.isEqual(b);
        if (b.isEqual && x.isFunction(b.isEqual)) return b.isEqual(a);
        var d = j.call(a);
        if (d != j.call(b)) return !1;
        switch (d) {
        case "[object String]":
            return a == String(b);
        case "[object Number]":
            return a != +a ? b != +b : a == 0 ? 1 / a == 1 / b : a == +b;
        case "[object Date]":
        case "[object Boolean]":
            return +a == +b;
        case "[object RegExp]":
            return a.source == b.source && a.global == b.global && a.multiline == b.multiline && a.ignoreCase == b.ignoreCase
        }
        if (typeof a != "object" || typeof b != "object") return !1;
        var e = c.length;
        while (e--) if (c[e] == a) return !0;
        c.push(a);
        var f = 0,
            g = !0;
        if (d == "[object Array]") {
            f = a.length, g = f == b.length;
            if (g) while (f--) if (!(g = f in a == f in b && B(a[f], b[f], c))) break
        } else {
            if ("constructor" in a != "constructor" in b || a.constructor != b.constructor) return !1;
            for (var h in a) if (k.call(a, h)) {
                f++;
                if (!(g = k.call(b, h) && B(a[h], b[h], c))) break
            }
            if (g) {
                for (h in b) if (k.call(b, h) && !(f--)) break;
                g = !f
            }
        }
        return c.pop(), g
    }
    var a = this,
        b = a._,
        c = {},
        d = Array.prototype,
        e = Object.prototype,
        f = Function.prototype,
        g = d.slice,
        h = d.concat,
        i = d.unshift,
        j = e.toString,
        k = e.hasOwnProperty,
        l = d.forEach,
        m = d.map,
        n = d.reduce,
        o = d.reduceRight,
        p = d.filter,
        q = d.every,
        r = d.some,
        s = d.indexOf,
        t = d.lastIndexOf,
        u = Array.isArray,
        v = Object.keys,
        w = f.bind,
        x = function (a) {
            return new D(a)
        };
    typeof exports != "undefined" ? (typeof module != "undefined" && module.exports && (exports = module.exports = x), exports._ = x) : typeof define == "function" && define.amd ? define("underscore", function () {
        return x
    }) : a._ = x, x.VERSION = "1.2.3";
    var y = x.each = x.forEach = function (a, b, d) {
            if (a == null) return;
            if (l && a.forEach === l) a.forEach(b, d);
            else if (a.length === +a.length) {
                for (var e = 0, f = a.length; e < f; e++) if (e in a && b.call(d, a[e], e, a) === c) return
            } else for (var g in a) if (k.call(a, g) && b.call(d, a[g], g, a) === c) return
        };
    x.map = function (a, b, c) {
        var d = [];
        return a == null ? d : m && a.map === m ? a.map(b, c) : (y(a, function (a, e, f) {
            d[d.length] = b.call(c, a, e, f)
        }), d)
    }, x.reduce = x.foldl = x.inject = function (a, b, c, d) {
        var e = arguments.length > 2;
        a == null && (a = []);
        if (n && a.reduce === n) return d && (b = x.bind(b, d)), e ? a.reduce(b, c) : a.reduce(b);
        y(a, function (a, f, g) {
            e ? c = b.call(d, c, a, f, g) : (c = a, e = !0)
        });
        if (!e) throw new TypeError("Reduce of empty array with no initial value");
        return c
    }, x.reduceRight = x.foldr = function (a, b, c, d) {
        var e = arguments.length > 2;
        a == null && (a = []);
        if (o && a.reduceRight === o) return d && (b = x.bind(b, d)), e ? a.reduceRight(b, c) : a.reduceRight(b);
        var f = x.toArray(a).reverse();
        return d && !e && (b = x.bind(b, d)), e ? x.reduce(f, b, c, d) : x.reduce(f, b)
    }, x.find = x.detect = function (a, b, c) {
        var d;
        return z(a, function (a, e, f) {
            if (b.call(c, a, e, f)) return d = a, !0
        }), d
    }, x.filter = x.select = function (a, b, c) {
        var d = [];
        return a == null ? d : p && a.filter === p ? a.filter(b, c) : (y(a, function (a, e, f) {
            b.call(c, a, e, f) && (d[d.length] = a)
        }), d)
    }, x.reject = function (a, b, c) {
        var d = [];
        return a == null ? d : (y(a, function (a, e, f) {
            b.call(c, a, e, f) || (d[d.length] = a)
        }), d)
    }, x.every = x.all = function (a, b, d) {
        var e = !0;
        return a == null ? e : q && a.every === q ? a.every(b, d) : (y(a, function (a, f, g) {
            if (!(e = e && b.call(d, a, f, g))) return c
        }), e)
    };
    var z = x.some = x.any = function (a, b, d) {
            b || (b = x.identity);
            var e = !1;
            return a == null ? e : r && a.some === r ? a.some(b, d) : (y(a, function (a, f, g) {
                if (e || (e = b.call(d, a, f, g))) return c
            }), !! e)
        };
    x.include = x.contains = function (a, b) {
        var c = !1;
        return a == null ? c : s && a.indexOf === s ? a.indexOf(b) != -1 : (c = z(a, function (a) {
            return a === b
        }), c)
    }, x.invoke = function (a, b) {
        var c = g.call(arguments, 2);
        return x.map(a, function (a) {
            return (b.call ? b || a : a[b]).apply(a, c)
        })
    }, x.pluck = function (a, b) {
        return x.map(a, function (a) {
            return a[b]
        })
    }, x.max = function (a, b, c) {
        if (!b && x.isArray(a)) return Math.max.apply(Math, a);
        if (!b && x.isEmpty(a)) return -Infinity;
        var d = {
            computed: -Infinity
        };
        return y(a, function (a, e, f) {
            var g = b ? b.call(c, a, e, f) : a;
            g >= d.computed && (d = {
                value: a,
                computed: g
            })
        }), d.value
    }, x.min = function (a, b, c) {
        if (!b && x.isArray(a)) return Math.min.apply(Math, a);
        if (!b && x.isEmpty(a)) return Infinity;
        var d = {
            computed: Infinity
        };
        return y(a, function (a, e, f) {
            var g = b ? b.call(c, a, e, f) : a;
            g < d.computed && (d = {
                value: a,
                computed: g
            })
        }), d.value
    }, x.shuffle = function (a) {
        var b = [],
            c;
        return y(a, function (a, d, e) {
            d == 0 ? b[0] = a : (c = Math.floor(Math.random() * (d + 1)), b[d] = b[c], b[c] = a)
        }), b
    }, x.sortBy = function (a, b, c) {
        return x.pluck(x.map(a, function (a, d, e) {
            return {
                value: a,
                criteria: b.call(c, a, d, e)
            }
        }).sort(function (a, b) {
            var c = a.criteria,
                d = b.criteria;
            return c < d ? -1 : c > d ? 1 : 0
        }), "value")
    }, x.groupBy = function (a, b) {
        var c = {},
            d = x.isFunction(b) ? b : function (a) {
                return a[b]
            };
        return y(a, function (a, b) {
            var e = d(a, b);
            (c[e] || (c[e] = [])).push(a)
        }), c
    }, x.sortedIndex = function (a, b, c) {
        c || (c = x.identity);
        var d = 0,
            e = a.length;
        while (d < e) {
            var f = d + e >> 1;
            c(a[f]) < c(b) ? d = f + 1 : e = f
        }
        return d
    }, x.toArray = function (a) {
        return a ? a.toArray ? a.toArray() : x.isArray(a) ? g.call(a) : x.isArguments(a) ? g.call(a) : x.values(a) : []
    }, x.size = function (a) {
        return x.toArray(a).length
    }, x.first = x.head = function (a, b, c) {
        return b != null && !c ? g.call(a, 0, b) : a[0]
    }, x.initial = function (a, b, c) {
        return g.call(a, 0, a.length - (b == null || c ? 1 : b))
    }, x.last = function (a, b, c) {
        return b != null && !c ? g.call(a, Math.max(a.length - b, 0)) : a[a.length - 1]
    }, x.rest = x.tail = function (a, b, c) {
        return g.call(a, b == null || c ? 1 : b)
    }, x.compact = function (a) {
        return x.filter(a, function (a) {
            return !!a
        })
    }, x.flatten = function (a, b) {
        return x.reduce(a, function (a, c) {
            return x.isArray(c) ? a.concat(b ? c : x.flatten(c)) : (a[a.length] = c, a)
        }, [])
    }, x.without = function (a) {
        return x.difference(a, g.call(arguments, 1))
    }, x.uniq = x.unique = function (a, b, c) {
        var d = c ? x.map(a, c) : a,
            e = [];
        return x.reduce(d, function (c, d, f) {
            if (0 == f || (b === !0 ? x.last(c) != d : !x.include(c, d))) c[c.length] = d, e[e.length] = a[f];
            return c
        }, []), e
    }, x.union = function () {
        return x.uniq(x.flatten(arguments, !0))
    }, x.intersection = x.intersect = function (a) {
        var b = g.call(arguments, 1);
        return x.filter(x.uniq(a), function (a) {
            return x.every(b, function (b) {
                return x.indexOf(b, a) >= 0
            })
        })
    }, x.difference = function (a) {
        var b = x.flatten(g.call(arguments, 1));
        return x.filter(a, function (a) {
            return !x.include(b, a)
        })
    }, x.zip = function () {
        var a = g.call(arguments),
            b = x.max(x.pluck(a, "length")),
            c = new Array(b);
        for (var d = 0; d < b; d++) c[d] = x.pluck(a, "" + d);
        return c
    }, x.indexOf = function (a, b, c) {
        if (a == null) return -1;
        var d, e;
        if (c) return d = x.sortedIndex(a, b), a[d] === b ? d : -1;
        if (s && a.indexOf === s) return a.indexOf(b);
        for (d = 0, e = a.length; d < e; d++) if (d in a && a[d] === b) return d;
        return -1
    }, x.lastIndexOf = function (a, b) {
        if (a == null) return -1;
        if (t && a.lastIndexOf === t) return a.lastIndexOf(b);
        var c = a.length;
        while (c--) if (c in a && a[c] === b) return c;
        return -1
    }, x.range = function (a, b, c) {
        arguments.length <= 1 && (b = a || 0, a = 0), c = arguments[2] || 1;
        var d = Math.max(Math.ceil((b - a) / c), 0),
            e = 0,
            f = new Array(d);
        while (e < d) f[e++] = a, a += c;
        return f
    };
    var A = function () {};
    x.bind = function (a, b) {
        var c, d;
        if (a.bind === w && w) return w.apply(a, g.call(arguments, 1));
        if (!x.isFunction(a)) throw new TypeError;
        return d = g.call(arguments, 2), c = function () {
            if (this instanceof c) {
                A.prototype = a.prototype;
                var e = new A,
                    f = a.apply(e, d.concat(g.call(arguments)));
                return Object(f) === f ? f : e
            }
            return a.apply(b, d.concat(g.call(arguments)))
        }
    }, x.bindAll = function (a) {
        var b = g.call(arguments, 1);
        return b.length == 0 && (b = x.functions(a)), y(b, function (b) {
            a[b] = x.bind(a[b], a)
        }), a
    }, x.memoize = function (a, b) {
        var c = {};
        return b || (b = x.identity), function () {
            var d = b.apply(this, arguments);
            return k.call(c, d) ? c[d] : c[d] = a.apply(this, arguments)
        }
    }, x.delay = function (a, b) {
        var c = g.call(arguments, 2);
        return setTimeout(function () {
            return a.apply(a, c)
        }, b)
    }, x.defer = function (a) {
        return x.delay.apply(x, [a, 1].concat(g.call(arguments, 1)))
    }, x.throttle = function (a, b) {
        var c, d, e, f, g, h = x.debounce(function () {
            g = f = !1
        }, b);
        return function () {
            c = this, d = arguments;
            var i = function () {
                    e = null, g && a.apply(c, d), h()
                };
            e || (e = setTimeout(i, b)), f ? g = !0 : a.apply(c, d), h(), f = !0
        }
    }, x.debounce = function (a, b) {
        var c;
        return function () {
            var d = this,
                e = arguments,
                f = function () {
                    c = null, a.apply(d, e)
                };
            clearTimeout(c), c = setTimeout(f, b)
        }
    }, x.once = function (a) {
        var b = !1,
            c;
        return function () {
            return b ? c : (b = !0, c = a.apply(this, arguments))
        }
    }, x.wrap = function (a, b) {
        return function () {
            var c = h.apply([a], arguments);
            return b.apply(this, c)
        }
    }, x.compose = function () {
        var a = arguments;
        return function () {
            var b = arguments;
            for (var c = a.length - 1; c >= 0; c--) b = [a[c].apply(this, b)];
            return b[0]
        }
    }, x.after = function (a, b) {
        return a <= 0 ? b() : function () {
            if (--a < 1) return b.apply(this, arguments)
        }
    }, x.keys = v || function (a) {
        if (a !== Object(a)) throw new TypeError("Invalid object");
        var b = [];
        for (var c in a) k.call(a, c) && (b[b.length] = c);
        return b
    }, x.values = function (a) {
        return x.map(a, x.identity)
    }, x.functions = x.methods = function (a) {
        var b = [];
        for (var c in a) x.isFunction(a[c]) && b.push(c);
        return b.sort()
    }, x.extend = function (a) {
        return y(g.call(arguments, 1), function (b) {
            for (var c in b) b[c] !== void 0 && (a[c] = b[c])
        }), a
    }, x.defaults = function (a) {
        return y(g.call(arguments, 1), function (b) {
            for (var c in b) a[c] == null && (a[c] = b[c])
        }), a
    }, x.clone = function (a) {
        return x.isObject(a) ? x.isArray(a) ? a.slice() : x.extend({}, a) : a
    }, x.tap = function (a, b) {
        return b(a), a
    }, x.isEqual = function (a, b) {
        return B(a, b, [])
    }, x.isEmpty = function (a) {
        if (x.isArray(a) || x.isString(a)) return a.length === 0;
        for (var b in a) if (k.call(a, b)) return !1;
        return !0
    }, x.isElement = function (a) {
        return !!a && a.nodeType == 1
    }, x.isArray = u || function (a) {
        return j.call(a) == "[object Array]"
    }, x.isObject = function (a) {
        return a === Object(a)
    }, x.isArguments = function (a) {
        return j.call(a) == "[object Arguments]"
    }, x.isArguments(arguments) || (x.isArguments = function (a) {
        return !!a && !! k.call(a, "callee")
    }), x.isFunction = function (a) {
        return j.call(a) == "[object Function]"
    }, x.isString = function (a) {
        return j.call(a) == "[object String]"
    }, x.isNumber = function (a) {
        return j.call(a) == "[object Number]"
    }, x.isNaN = function (a) {
        return a !== a
    }, x.isBoolean = function (a) {
        return a === !0 || a === !1 || j.call(a) == "[object Boolean]"
    }, x.isDate = function (a) {
        return j.call(a) == "[object Date]"
    }, x.isRegExp = function (a) {
        return j.call(a) == "[object RegExp]"
    }, x.isNull = function (a) {
        return a === null
    }, x.isUndefined = function (a) {
        return a === void 0
    }, x.noConflict = function () {
        return a._ = b, this
    }, x.identity = function (a) {
        return a
    }, x.times = function (a, b, c) {
        for (var d = 0; d < a; d++) b.call(c, d)
    }, x.escape = function (a) {
        return ("" + a).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#x27;").replace(/\//g, "&#x2F;")
    }, x.mixin = function (a) {
        y(x.functions(a), function (b) {
            F(b, x[b] = a[b])
        })
    };
    var C = 0;
    x.uniqueId = function (a) {
        var b = C++;
        return a ? a + b : b
    }, x.templateSettings = {
        evaluate: /<%([\s\S]+?)%>/g,
        interpolate: /<%=([\s\S]+?)%>/g,
        escape: /<%-([\s\S]+?)%>/g
    }, x.template = function (a, b) {
        var c = x.templateSettings,
            d = "var __p=[],print=function(){__p.push.apply(__p,arguments);};with(obj||{}){__p.push('" + a.replace(/\\/g, "\\\\").replace(/'/g, "\\'").replace(c.escape, function (a, b) {
                return "',_.escape(" + b.replace(/\\'/g, "'") + "),'"
            }).replace(c.interpolate, function (a, b) {
                return "'," + b.replace(/\\'/g, "'") + ",'"
            }).replace(c.evaluate || null, function (a, b) {
                return "');" + b.replace(/\\'/g, "'").replace(/[\r\n\t]/g, " ") + ";__p.push('"
            }).replace(/\r/g, "\\r").replace(/\n/g, "\\n").replace(/\t/g, "\\t") + "');}return __p.join('');",
            e = new Function("obj", "_", d);
        return b ? e(b, x) : function (a) {
            return e.call(this, a, x)
        }
    };
    var D = function (a) {
            this._wrapped = a
        };
    x.prototype = D.prototype;
    var E = function (a, b) {
            return b ? x(a).chain() : a
        },
        F = function (a, b) {
            D.prototype[a] = function () {
                var a = g.call(arguments);
                return i.call(a, this._wrapped), E(b.apply(x, a), this._chain)
            }
        };
    x.mixin(x), y(["pop", "push", "reverse", "shift", "sort", "splice", "unshift"], function (a) {
        var b = d[a];
        D.prototype[a] = function () {
            return b.apply(this._wrapped, arguments), E(this._wrapped, this._chain)
        }
    }), y(["concat", "join", "slice"], function (a) {
        var b = d[a];
        D.prototype[a] = function () {
            return E(b.apply(this._wrapped, arguments), this._chain)
        }
    }), D.prototype.chain = function () {
        return this._chain = !0, this
    }, D.prototype.value = function () {
        return this._wrapped
    }
})).call(this), function () {



// HERE WE Go-------
// Main part of sdk





    var a, b = function (a, b) {
            return function () {
                return a.apply(b, arguments)
            }
        };
    a = function () {function a(a) {
            this.el = a, this.change = b(this.change, this), this.setupElements(), this.bindEvents(), this.change()
        }
        return a.prototype.setupElements = function () {
            return this.checkbox = this.el.find("input[type=checkbox]"), this.details = this.el.find(".details")
        }, a.prototype.bindEvents = function () {
            return this.checkbox.bind("change", this.change)
        }, a.prototype.change = function (a) {
            return this.checkbox[0].checked ? this.details.show() : this.details.hide()
        }, a
    }(), this.PublishDate = a


}.call(this);

(function($){

$(function () {
    // $("#change_password",'.__sdk').hide(), $("#change_password_link",'.__sdk').click(function () {
    //     return $(this).hide(), $("#change_password",'.__sdk').show(), !1
    // })
}), $(function () {
    if ($("#categories",'.__sdk')) {
        var a = $("#categories",'.__sdk'),
            b = $("#new_category",'.__sdk');
        b.ajaxForm({
            success: function (d) {
                b.hide(), b.find("input[type=text]").val(""), b.parent().find("span").show(), a.append(d), c()
            }
        });
        var c = function () {
                a.find(".editable").editable(), a.find("form.edit_category").each(function () {
                    var a = $(this),
                        b = a.parent().find("span");
                    a.ajaxForm({
                        dataType: "json",
                        success: function (c) {
                            a.hide(), b.text(c.name).show()
                        }
                    })
                }), a.find("a.delete").live("ajax:success", function (a) {
                    $(this).parent().remove()
                })
            };
        c()
    }
}), jQuery(function (a) {
    return a(".datepicker").datepicker({
        beforeShow: function() {
            // $(this).datepicker("widget").wrap('<div class="__sdk"></div>');
        },
        onClose: function() {

        }
    })
}), $("a.follow",'.__sdk').live("ajax:success", function (a, b) {
    $(this).closest("li").html(b)
}), $(function () {
    if ($("#presentation",'.__sdk')) {
        var a = $("#presentation",'.__sdk');
        $("ul.delimited a.likes",'.__sdk').click(function () {
            $('#tabs a[href="#fans"]','.__sdk').click()
        });
    }
}), $(function () {
    $("div.preview",'.__sdk').hover(function () {
        $(this).addClass("preview_hover")
    }, function () {
        $(this).removeClass("preview_hover")
    }), $("div.preview",'.__sdk').click(function () {
        window.location.href = $(this).children("a").attr("href")
    }), $("#new_presentation",'.__sdk').live("submit", function () {
        if ($(this).closest(".uploaded").length == 0) return !1
    }), $("[data-processing-presentation]",'.__sdk').each(function () {
        var a = $(this),
            b = a.attr("data-processing-presentation");
        setTimeout(function () {
            showProcessProgress(b)
        }, 2e3)
    })
});
KTV.sdk_scrub = function () {
    jQuery("a.scrub",'.__sdk').mousemove(function (a) {
        var b = jQuery(this),
            c = b.closest(".presentation"),
            d = b.find(".scrubbed"),
            e = parseInt(c.attr("data-slide-count"), 10);
        if (!b.hasClass("setup")) {
            b.addClass("setup");
            var f = c.attr("data-id"),
                g = b.find("img").attr("src").replace(/0\.jpg$/, "");
            for (var h = 1; h < e; h++) b.prepend('<img src="' + g + h + '.jpg" alt="Slide ' + (h + 1) + '" class="timeline" data-slide="' + h + '" style="display:none;" />')
        }
				console.log("a.pageX="+a.pageX.toString()+";b.position().left="+b.position().left.toString());
        var i = 180,
            j = a.pageX - b.position().left - 15,
            k = j > 180 ? 180 : j < 0 ? 0 : j,
            l = k / i,
            m = Math.floor(l * e) - 1;
				console.log("e="+e.toString()+";k="+k.toString()+";i="+i.toString()+";j="+j.toString());
        m > e && (m = e), m < 0 && (m = 0), b.find("img[data-slide]:visible").hide(), b.find("img[data-slide=" + m + "]").show(), b.find(".scrubbed").width(Math.round((m + 1) * 100 / e) + "%")
    }).mouseleave(function () {
        jQuery(this).find("img[data-slide]:visible").hide()
    })
};

$(document).bind("ready pjax:end", KTV.sdk_scrub), jQuery(function (a) {
    // var b, c, d, e;
    // return b = a("#search_form"), c = a("#q"), d = c.val(), b.bind("submit", function () {
    //     return !1
    // }), e = function (e) {
    //     var f;
    //     f = c.val();
    //     if (f.length > 1 && f !== d) return d = f, b.addClass("searching"), a.pjax({
    //         url: "/search?" + a.param({
    //             q: c.val()
    //         }),
    //         container: "#content",
    //         timeout: 3e3,
    //         success: function () {
    //             return b.removeClass("searching")
    //         }
    //     })
    // }, c.bind("keyup", _.debounce(e, 350))
}), $(function () {
    $("#new_session",'.__sdk').dialog({
        autoOpen: !1,
        modal: !0,
        resizable: !1,
        draggable: !1,
        width: 296,
        buttons: {
            "Sign In": function () {
                $(this).find("form").submit()
            }
        }
    }), $("#new_session form",'.__sdk').live("submit", function () {
        return $("#new_session",'.__sdk').closest(".ui-dialog").find("button").css("opacity", .3), $("#new_session p.error",'.__sdk').remove(), $(this).ajaxSubmit({
            dataType: "json",
            success: function (a) {
                a.error ? ($("#new_session",'.__sdk').prepend('<p class="error">' + a.error + "</p>"), $("#new_session",'.__sdk').closest(".ui-dialog").find("button").css("opacity", 1), $("#new_session",'.__sdk').dialog("open")) : window.location.reload()
            }
        }), !1
    }), $("#new_session input",'.__sdk').keypress(function (a) {
        a.keyCode == 13 && $("#new_session form",'.__sdk').submit()
    }), $("#sign_in",'.__sdk').click(function () {
        return $("#new_session p.error",'.__sdk').remove(), $("#new_session",'.__sdk').dialog("open"), $("#email",'.__sdk').focus(), !1
    }), $("button",'.__sdk').each(function () {
        $(this).html('<span class="' + ($(this).hasClass("primary") ? "primary" : "") + '">' + $(this).html() + "</span>").removeClass("primary")
    })
}), $(function () {
    $("#share_social",'.__sdk').click(function () {
        return window.frames[0].window.$("#presenter",'.__sdk').addClass("share"), window.frames[0].window.$('a[href="#social"]','.__sdk').click(), !1
    }), $("#share_embed",'.__sdk').click(function () {
        return window.frames[0].window.$("#presenter",'.__sdk').addClass("share"), window.frames[0].window.$('a[href="#embed"]','.__sdk').click(), !1
    }), $("#share_link",'.__sdk').click(function () {
        return window.frames[0].window.$("#presenter",'.__sdk').addClass("share"), window.frames[0].window.$('a[href="#link"]','.__sdk').click(), !1
    })
}), $(function () {
    if ($("#tabs",'.__sdk')) {
        var a = $("#tabs",'.__sdk');
        a.find("a").click(function () {
          if('#comments'==$(this).attr('href')){
            $('#the_ytb').show();
          }else{
            $('#the_ytb').hide();
          }
            return $(".tab-content",'.__sdk').hide(), $($(this).attr("href")).show(), $(this).closest("ul").find("li.current").removeClass("current"), $(this).closest("li").addClass("current"), !1
        }).first().click()
                
        //  a.find('a[href="#fans"]').click(function () {
        //     $.ajax({
        //         url: window.location.pathname + "/fans",
        //         success: function (a) {
        //             var b = $("#fans table",'.__sdk');
        //             return b.empty(), b.append(a), !1
        //         }
        //     })
        // })
    }
}), function () {
    var a, b, c, d = Object.prototype.hasOwnProperty,
        e = function (a, b) {function e() {
                this.constructor = a
            }
            for (var c in b) d.call(b, c) && (a[c] = b[c]);
            return e.prototype = b.prototype, a.prototype = new e, a.__super__ = b.prototype, a
        };
    c = function () {function a(a) {
            this.form = a
        }
        return a.prototype.start = function (a) {
            return $(".qq-uploader",'.__sdk').addClass("selected"), $("#upload_progress",'.__sdk').addClass("active").removeClass("inactive"), $("#upload_progress .progress_title",'.__sdk').text("正在上传 " + a)
        }, a.prototype.progress = function (a, b) {
            var c;
            return c = "已上传 " + this.formatSize(a), a !== b && (c += ", 共" + this.formatSize(b)), $("#upload_progress .progress_title",'.__sdk').text(c), $("#upload_progress .progress_meter",'.__sdk').width(a * 100 / b + "%")
        }, a.prototype.complete = function (a) {
            return $("#the_slides",'.__sdk').remove(), this.form.attr("action", "/presentations/" + a.id).append('<input type="hidden" name="_method" value="PUT" />').addClass("uploaded"), $(".presentation_wrapper",'.__sdk').attr("id", "presentation_" + a.id), $("#process_progress",'.__sdk').addClass("active").closest(".step").attr("data-processing-presentation", a.id), showProcessProgress(a.id)
        }, a.prototype.formatSize = function (a) {
            var b;
            b = -1;
            while (a > 99) a /= 1024, b++;
            return Math.max(a, .1).toFixed(1) + ["KB", "MB", "GB", "TB", "PB", "EB"][b]
        }, a
    }(), b = function () {function a() {
            a.__super__.constructor.apply(this, arguments), this.container = $("#uploader",'.__sdk'), this.setup()
        }
        return e(a, c), a.prototype.setup = function () {
            var a, b = this;
            return this.form.find('input[name="presentation[id]"]').remove(), a = {
                authenticity_token: $("meta[name=csrf-token]",'.__sdk').attr("content")
            }, a[this.container.data("session-key-name")] = this.container.data("session-key"), this.uploader = new qq.FileUploader({
                allowedExtensions: ["pdf",'djvu','ppt','pptx','doc','docx','zip','rar','7z'],
                element: this.container.get(0),
                action: this.form.attr("action") + ".json",
                requestType: this.form.find("input[name=_method]").val() || "POST",
                multiple: !1,
                params: a,
                template: '<div class="qq-uploader">                  <div class="qq-upload-button">                    <div class="qq-upload-drop-area"><span>Drop files here to upload</span></div>                    <span class="button primary select">选择要上传的文件</span>                    <span class="button primary cancel">文件已选定</span>                  </div>                  <ul class="qq-upload-list"></ul>                </div>',
                onProgress: function (a, c, d, e) {
                    return b.progress(d, e)
                },
                onComplete: function (a, c, d) {
                    return b.complete(d)
                },
                onSubmit: function (a, c) {
                    return b.start(c)
                }
            })
        }, a
    }(), a = function () {function a() {
            a.__super__.constructor.apply(this, arguments), this.config = this.form.data("s3"), this.setup()
        }
        return e(a, c), a.prototype.setup = function () {
            var a = this;
            return $("#uploader",'.__sdk').append('<div class="qq-uploader">        <div class="qq-upload-button">          <span class="button primary select">选择要上传的文件</span>          <span class="button primary cancel">文件已选定</span>        </div>        <ul class="qq-upload-list"></ul>      </div>'), $("#presentation_pdf",'.__sdk').uploadify({
                uploader: "/flash/uploadify.swf",
                hideButton: !0,
                wmode: "transparent",
                width: 200,
                height: 49,
                script: "http://v0.api.upyun.com/ktv-up/",//'http://kejian.lvh.me/ktv',
                fileDataName: "file",
                scriptData: {
                    policy: encodeURIComponent(encodeURIComponent(this.config.policy)),
                    signature: encodeURIComponent(encodeURIComponent(this.config.signature)),
                },
                fileDesc: "Presentation",
                fileExt: "*.pdf; *.djvu; *.ppt; *.pptx; *.doc; *.docx; *.zip; *.rar; *.7z",
                onSelect: function (b, c, d) {
                    $('#presentation_title').val($('#presentation_title').val()+((d.name.lastIndexOf(".") != -1) ? d.name.substring(0, d.name.lastIndexOf(".")) : d.name));
                    $('#biaozhu_cw').show();
                    return $("#presentation_pdfUploader",'.__sdk').css({
                        left: "-5000px"
                    }), a.start(d.name)
                },
                onComplete: function (b, c, d, e) {
                    a.form.attr("enctype", "").find("input#presentation_pdf").remove();
                    a.form.ajaxSubmit({
                        url: a.form.attr("action") + ".json",
                        data: {
                            "presentation[pdf_filename]": d.name
                        },
                        dataType: "json",
                        success: function (b) {
                            return a.complete(b)
                        }
                    });
                    $('#ok_to_leave').show();
                    $("#ok_to_leave").fadeOut('fast').fadeIn('fast').fadeOut('fast').fadeIn('fast');
                },
                onProgress: function (b, c, d, e) {
                    return a.progress(e.bytesLoaded, d.size)
                },
                scriptAccess: "always",
                queueID: "uploadifyQueue",
                auto: !0,
                folder: "",
                sizeLimit: 104857600,
                multi: !1
            })
        }, a
    }(), a.supported = function (a) {
        return FlashDetect.installed && a.data("s3")
    }, jQuery(function () {
        var c;
        c = $("#upload_presentation",'.__sdk');
        if (c.length > 0) return a.supported(c) ? window.uploader = new a(c) : window.uploader = new b(c)
    })
}.call(this);

})(jQuery);