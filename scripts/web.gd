class_name Web extends Node


@export var iframe_cover: Control


func show_video(video_id: String) -> void:
    if not OS.has_feature("web"):
        return

    iframe_cover.visible = true

    var js := """
    (function() {
        let f = document.getElementById('yt_overlay');

        if (!f) {
            f = document.createElement('iframe');
            f.id = 'yt_overlay';
            f.title = 'Embedded Video'
            f.style.position = 'absolute';
            f.style.border = '0';
            f.frameborder = '0'
            f.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share; fullscreen';
            f.referrerpolicy = "strict-origin-when-cross-origin"
            document.body.appendChild(f);
        }

        f.src = 'https://www.youtube.com/embed/{id}';
        f.style.left = '40px';
        f.style.top = '80px';
        f.style.width = 'calc(100% - 80px)';
        f.style.height = 'calc(100% - 120px)';
    })();
    """.format({"id": video_id})
    JavaScriptBridge.eval(js)

func hide_video():
    JavaScriptBridge.eval("document.getElementById('yt_overlay')?.remove();")
    iframe_cover.visible = false
