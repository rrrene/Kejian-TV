var utils = require("utils::index");

module.exports = run;

function run() {

// IE9 thinks the argument is not optional
// FF thinks the argument is not optional
// Opera agress that its not optional
(function () {
    var e = document.createElement("div");
    try {
        document.importNode(e);
    } catch (e) {
        var importNode = document.importNode;
        delete document.importNode;
        document.importNode = function _importNode(node, bool) {
            if (bool === undefined) {
                bool = true;
            }
            return importNode.call(this, node, bool);
        }
    }
})();

// Firefox fails on .cloneNode thinking argument is not optional
// Opera agress that its not optional.
(function () {
    var el = document.createElement("p");

    try {
        el.cloneNode();
    } catch (e) {
        [
            Node.prototype,
            Comment.prototype,
            Element.prototype,
            ProcessingInstruction.prototype,
            Document.prototype,
            DocumentType.prototype,
            DocumentFragment.prototype
        ].forEach(fixNodeOnProto);

        utils.HTMLNames.forEach(forAllHTMLInterfaces)
    }

    function forAllHTMLInterfaces(name) {
        window[name] && fixNodeOnProto(window[name].prototype);
    }

    function fixNodeOnProto(proto) {
        var cloneNode = proto.cloneNode;
        delete proto.cloneNode;
        proto.cloneNode = function _cloneNode(bool) {
            if (bool === undefined) {
                bool = true;
            }  
            return cloneNode.call(this, bool);
        };    
    }
})();

// Opera is funny about the "optional" parameter on addEventListener
(function () {
    var count = 0;
    var handler = function () {
        count++;
    }
    document.addEventListener("click", handler);
    var ev = new Event("click");
    document.dispatchEvent(ev);
    if (count === 0) {
        // fix opera
        var oldListener = EventTarget.prototype.addEventListener;
        EventTarget.prototype.addEventListener = function (ev, cb, optional) {
            optional = optional || false;
            return oldListener.call(this, ev, cb, optional);
        };
        // fix removeEventListener aswell
        var oldRemover = EventTarget.prototype.removeEventListener;
        EventTarget.prototype.removeEventListener = function (ev, cb, optional) {
            optional = optional || false;
            return oldRemover.call(this, ev, cb, optional);
        };
        // punch window.
        window.addEventListener = EventTarget.prototype.addEventListener;
        window.removeEventListener = EventTarget.prototype.removeEventListener;
    }
    document.removeEventListener("click", handler);
})();

}