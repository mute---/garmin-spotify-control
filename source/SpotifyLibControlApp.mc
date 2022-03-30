import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.System;

const TOKEN_STORAGE_KEY = "refresh_token";

class SpotifyLibControlApp extends Application.AppBase {

    private var _authService as AuthService;

    function initialize() {
        System.println("App init"); 

        AppBase.initialize();

        _authService = new AuthService(getProperty("ClientId"));
        _authService.subscribe(method(:onLogin));
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        System.println("App onStart");

        var token = Application.Storage.getValue(TOKEN_STORAGE_KEY);
        if (token == null) {
            // Authorize
            System.println("Authorize");
            _authService.authorize();
        } else {
            // Refresh
            System.println("Refresh");
            _authService.refresh(token);
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Communications.cancelAllRequests();

        Application.Storage.setValue(TOKEN_STORAGE_KEY, _authService.getRefreshToken());
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {

        return [ new LoginView() ];
    }

    function onLogin(prop) {
        if (prop == :refreshToken) {
            storeToken();
            return;
        }

        if (_authService.isAuthenticated()) {
            var spotifyService = new SpotifyService(new HttpHelper(_authService.method(:getAccessToken)), _authService.method(:refreshToken));

            WatchUi.switchToView(new SpotifyLibControlView(spotifyService), new SpotifyLibControlViewDelegate(spotifyService), WatchUi.SLIDE_IMMEDIATE);
        } else {
            if (_authService.getRefreshToken() != null) {
                WatchUi.switchToView(new LoginView(), null, WatchUi.SLIDE_IMMEDIATE);
                _authService.authorize();
            }
        }
    }

    private function storeToken() {
        Application.Storage.setValue(TOKEN_STORAGE_KEY, _authService.getRefreshToken());
    }
}

function getApp() as SpotifyLibControlApp {
    return Application.getApp() as SpotifyLibControlApp;
}