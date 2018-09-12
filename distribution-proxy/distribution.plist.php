<?php
/* Define XML content type and prolog */
header('Content-Type: text/xml');
print('<?xml version="1.0" encoding="UTF-8"?>');
print("\n");

/* Generate plist file */
?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>assets</key>
            <array>
                <dict>
                    <key>kind</key>
                    <string>software-package</string>
                    <key>url</key>
                    <string><?php print(str_replace(" ", "%20", $_REQUEST["ipa_url"])); ?></string>
                </dict>
            </array>
            <key>metadata</key>
            <dict>
                <key>bundle-identifier</key>
                <string><?php print($_REQUEST["bundleId"]); ?></string>
                <key>bundle-version</key>
                <string><?php print($_REQUEST["version"]); ?></string>
                <key>kind</key>
                <string>software</string>
                <key>title</key>
                <string><?php print($_REQUEST["title"]); ?></string>
            </dict>
        </dict>
    </array>
</dict>
</plist>
