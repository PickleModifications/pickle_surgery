function ShowHUD(data) {
    if (data.showInfo) {
        $("#app-info").fadeIn(500)
    }
    $("#hud-blood").html(data.blood + "ml")
    $("#app-hud").fadeIn(500)
}

function HideHUD() {
    $("#app-hud").fadeOut(500)
    $("#app-info").fadeOut(500)
}

function UpdateHUD(data) {
    $("#hud-blood").html(data.blood + "ml")
}

window.addEventListener("message", function(ev) {
    if (ev.data.type == "showHud") {
        ShowHUD(ev.data.data)
    }
    else if (ev.data.type == "hideHud") {
        HideHUD()
    }
    else if (ev.data.type == "updateHud") {
        UpdateHUD(ev.data.data)
    }
})