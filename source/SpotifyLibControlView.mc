import Toybox.Graphics;
import Toybox.WatchUi;

class SpotifyLibControlView extends WatchUi.View {

    private var _spotifyService as SpotifyService;

    private var _trackLabel as TextArea;
    private var _likeButton as Button;

    function initialize(spotifyService as SpotifyService) {
        View.initialize();

        _spotifyService = spotifyService;
        _spotifyService.subscribe(method(:onSpotifyChange));
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));

        _trackLabel = findDrawableById("CurrentTrackLabel");
        _likeButton = findDrawableById("LikeButton");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        _spotifyService.start();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var currentTrack = _spotifyService.currentTrack;
        if (currentTrack != null) {
            _trackLabel.setText(currentTrack.get("name"));
        }

        var isLiked = _spotifyService.isLiked;
        _likeButton.setState(isLiked ? :stateSelected : :stateDefault);
    }

    function onSpotifyChange(prop) {
        requestUpdate();
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        _spotifyService.stop();
    }

}
