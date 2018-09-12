<?php
/* Extract the IPA URL from the refererer's URL components */

$url_components = parse_url($_SERVER["HTTP_REFERER"]);
$hostname = $url_components["host"];
$app_path = dirname(dirname($url_components["path"]));
$app_name = basename($url_components["path"], ".html");

/* Compose a base URL if needed, otherwise use the preconfigured base URL that is defined in the /etc/ipa_proxy include */

global $baseURL;

if(is_file('/etc/ipa_proxy'))
    include('/etc/ipa_proxy');

if($baseURL == "")
{
    if($_SERVER["HTTPS"] == "")
        $protocol = "http://";
    else
        $protocol = "https://";
    
    $baseURL = $protocol.$hostname;
}

/* Compose the IPA URL */
$ipa_url = $baseURL.$app_path."/1/".$app_name.".ipa";

/* Compose parameters that are passed to the plist generator from the provided GET parameters */
$plistParams = urlencode("?ipa_url=".$ipa_url."&bundleId=".$_REQUEST["bundleId"]."&version=".$_REQUEST["version"]."&title=".$_REQUEST["title"]);

/* Display a page with links */
?>
<!DOCTYPE html>
<html>
    <head>
        <title>Install IPA files</title>
        <style type="text/css">
        body
        {
            text-align: center;
            padding: 10px;
            font-size: 400%;
        }
        </style>
    </head>
    <body>
        <p><a id="installipa" href="itms-services://?action=download-manifest&amp;url=<?php print($baseURL); ?>/distribution.plist.php<?php print($plistParams); ?>">Click this link to install the IPA</a></p>
        <p><a href="/">Go back to the Hydra entry page</a></p>

        <script type="text/javascript">
            setTimeout(function() {
                var link = document.getElementById('installipa');
                if(document.createEvent) {
                    var eventObj = document.createEvent('MouseEvents');
                    eventObj.initEvent('click', true, false);
                    link.dispatchEvent(eventObj);
                } else if(document.createEventObject) {
                    link.fireEvent('onclick');
                }
            }, 1000);
        </script>
    </body>
</html>
