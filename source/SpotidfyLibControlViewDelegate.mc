import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class SpotifyLibControlViewDelegate extends WatchUi.BehaviorDelegate {

    private var _spotifyService as SpotifyService;

    function initialize(spotifyService as SpotifyService) {
        BehaviorDelegate.initialize();

        _spotifyService = spotifyService;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean { 
        switch(keyEvent.getKey()) {
            case KEY_LAP: 
            case KEY_START:
                handleLikeClick();
                break;
        }

        return false;
    }

    function onSelectable(event) {
        System.println(event.getPreviousState());
    }

    function handleLikeClick() {
        if (_spotifyService.isLiked) {
            _spotifyService.dislikeTrack();
        } else {
            _spotifyService.likeTrack();
        }
    }
}