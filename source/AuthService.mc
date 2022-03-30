import Toybox.Communications;
import Toybox.Lang;
import Toybox.StringUtil;
import Toybox.Math;
import Toybox.StringUtil;
import Toybox.Cryptography;

import Util;

class AuthService extends Util.Observable {

    const URL_BASE = "https://accounts.spotify.com";
    const AUTH_URL = URL_BASE + "/authorize";
    const AUTH_TOKEN_URL = URL_BASE + "/api/token";

    const REDIRECT_URI = "https://localhost";
    const SCOPE = "user-read-currently-playing user-library-modify user-library-read";

    private var _accessToken as String;
    private var _refreshToken as String;
    private var _verifier as String;
    private var _clientId as String;
    private var _isAuthenticated as Boolean = false;

    function initialize(clientId as String) {
        Observable.initialize();

        _clientId = clientId;
        Communications.registerForOAuthMessages(method(:onAuthMessage));
    }

    function authorize() {
        _verifier = getRandomString();

        var hash = new Cryptography.Hash({:algorithm => Cryptography.HASH_SHA256});
        hash.update(convertToByteArray(_verifier));
        var codeChallenge = convertToBase64Url(hash.digest());

        Communications.makeOAuthRequest(AUTH_URL, 
                                        {
                                            "scope" => SCOPE,
                                            "response_type" => "code",
                                            "redirect_uri" => REDIRECT_URI,
                                            "client_id" => _clientId,
                                            "code_challenge_method" => "S256",
                                            "code_challenge" => codeChallenge
                                        }, 
                                        REDIRECT_URI, 
                                        Communications.OAUTH_RESULT_TYPE_URL,
                                        {
                                            "code" => "code",
                                            "error" => "error"
                                        });
    }

    function onAuthMessage(message) {
        if (message.responseCode != 200) {
            System.println("Erros on auth request");
            return false;
        }

        var params = {
            "code" => message.data["code"],
            "grant_type" => "authorization_code",
            "redirect_uri" => REDIRECT_URI,
            "client_id" => _clientId,
            "code_verifier" => _verifier
        };
        
        post(params);

        return true;
    }

    function onTokenAccuire(responseCode, data) {
        if (responseCode != 200) {
            System.println("Error aquiring token");
            _isAuthenticated = false;
            return;
        }
    
        _accessToken = data.get("access_token");

        if (data.hasKey("refresh_token")) {
            _refreshToken = data.get("refresh_token");
            notify(:refreshToken);
        }

        _isAuthenticated = true;
        notify(null);
    }

    function refreshToken() {
        refresh(_refreshToken);
    }

    function refresh(token as String) {
        var params = {
            "grant_type" => "refresh_token",
            "refresh_token" => token,
            "client_id" => _clientId
        };

        post(params);
    }

    function getRefreshToken() {
        return _refreshToken;
    }

    function getAccessToken() {
        return _accessToken;
    }

    function isAuthenticated() {
        return _isAuthenticated;
    }

    private function getRandomString() {
        Math.srand(System.getTimer());
        var allowedChars = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890-._~".toCharArray();

        var array = [];
        for (var i = 0; i < 69; i++) {
            array.add(allowedChars[Math.rand() % allowedChars.size()]);
        }
        return StringUtil.charArrayToString(array);
    }

    private function convertToBase64Url(bytes as ByteArray) {
        var base64 = StringUtil.convertEncodedString(bytes, {
            :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
            :toRepresentation => StringUtil.REPRESENTATION_STRING_BASE64
        }).toCharArray();

        var base64url = [];
        for (var i = 0; i < base64.size(); i++) {
            var char = base64[i];
            if (char == '+') {
                base64url.add('-');
            } else if (char == '/') {
                base64url.add('_');
            } else if (char == '=') {
                continue;
            } else {
                base64url.add(char);
            }
        }

        return StringUtil.charArrayToString(base64url);
    }

    private function convertToByteArray(string as String) {
        return StringUtil.convertEncodedString(string, {
            :fromRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
            :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY
        });
    }

    private function post(params) {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
            }
        };

        Communications.makeWebRequest(AUTH_TOKEN_URL, params, options, method(:onTokenAccuire));
    }
}