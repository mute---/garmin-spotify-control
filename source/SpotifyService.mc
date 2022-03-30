import Toybox.Lang;
import Toybox.System;
import Toybox.Communications;
import Toybox.Timer;

import Util;

class SpotifyService extends Util.Observable {

    private var _http as HttpHelper;
    private var _refreshToken as Method;

    var currentTrack as Dictionary;
    var isLiked as Boolean;
    var isPlaying as Boolean;
    var volumeLevel as Number;

    private var _trackTimer as Timer;

    private var _retryCount as Number = 0;

    function initialize(httpHelper as HttpHelper, tokenRefresher as Method) {
        Observable.initialize();

        _http = httpHelper;
        _refreshToken = tokenRefresher;

        _trackTimer = new Timer.Timer();
    }

    function start() {
        _trackTimer.start(method(:getCurrentTrack), 5000, true);
    }

    function stop() {
        _trackTimer.stop();
    }

    function getCurrentTrack() {
        _http.get("/me/player/currently-playing", {}, method(:onTrackResponse));
    }

    function onTrackResponse(code, data) {
        switch (code) {
            case 401: // Try refresh token first.
                handle401();
                break;

            case 200:
                isPlaying = data.get("is_playing");

                var newTrack = data.get("item");
                if (currentTrack != null && !newTrack.get("id").equals(currentTrack.get("id"))) {
                    isLiked = false;
                }
                checkIsLiked(newTrack.get("id"));

                currentTrack = newTrack;
                break;


            case 204: // No tracks currently playing.
            default: // Other errors.
                currentTrack = null;
                isLiked = false;
                isPlaying = false;
        }

        notify(:currentTrack);
    }

    function checkIsLiked(id as String) {
        _http.get("/me/tracks/contains", { "ids" => id }, method(:onTrackLiked));
    }

    function onTrackLiked(code, data as Array<Boolean>) {
        if (code == 401) {
            handle401();
        }

        if (code != 200) {
            return;
        }

        isLiked = data[0];
        notify(:currentTrack);
    }
    
    function likeTrack() {
        if (currentTrack == null) {
            return;
        }

        isLiked = true;
        notify(:currentTrack);

        _http.put("/me/tracks", { "ids" => [currentTrack.get("id")]}, method(:onLikeTrack));
    }

    function onLikeTrack(code, data) {
        if (code == 401) {
            handle401();
            return;
        }

        isLiked = code == 200;
        notify(:currentTrack);
    }

    function dislikeTrack() {
        if (currentTrack == null) {
            return;
        }

        isLiked = false;
        notify(:currentTrack);

        _http.delete("/me/tracks", { "ids" => currentTrack.get("id") }, method(:onDislikeTrack));
    }

    function onDislikeTrack(code, data) {
        if (code == 401) {
            handle401();
            return;
        }

        isLiked = code != 200;
        notify(:currentTrack);
    }

    private function handle401() {
        if (_retryCount > 1) { 
            _retryCount = 0;
            stop();
        } else {
            _retryCount++;
            _refreshToken.invoke();
        }
    }
}