import Toybox.Lang;
import Toybox.Communications;

class HttpHelper {

    const BASE_URL = "https://api.spotify.com/v1";
    private var _getToken as Method;

    function initialize(tokenGetter as Method) {
        _getToken = tokenGetter;
    }

    function get(url as String, params as Dictionary, callback as Method) {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Authorization" => "Bearer " + _getToken.invoke()
            }
        }; 

        Communications.makeWebRequest(BASE_URL + url, params, options, callback);
    }

    function put(url as String, params as Dictionary or Array, callback as Method) {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_PUT,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Authorization" => "Bearer " + _getToken.invoke(),
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
            }
        };

        Communications.makeWebRequest(BASE_URL + url, params, options, callback);
    }

    function post(url as String, params as Dictionary, callback as Method) {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Authorization" => "Bearer " + _getToken.invoke(),
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
            }
        };

        Communications.makeWebRequest(BASE_URL + url, params, options, callback);
    }

    function delete(url as String, params as Dictionary, callback as Method) {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_DELETE,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Authorization" => "Bearer " + _getToken.invoke()
            }
        }; 

        Communications.makeWebRequest(BASE_URL + url, params, options, callback);
    }
}