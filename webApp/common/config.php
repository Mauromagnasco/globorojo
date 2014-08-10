<?php
/**
 * Globo Rojo open source application
 *
 *  Copyright © 2013, 2014 by Mauro Magnasco <mauro.magnasco@gmail.com>
 *
 *  Licensed under GNU General Public License 2.0 or later.
 *  Some rights reserved. See COPYING, AUTHORS.
 *
 * @license GPL-2.0+ <http://spdx.org/licenses/GPL-2.0+>
 */
	define("DB_TYPE", "mysql");
	define("DB_HOSTNAME", "localhost");
	define("DB_USERNAME", "root");
	define("DB_PASSWORD", "apmsetup");
	define("DB_DATABASE", "redballoon");
	define("HOST_SERVER", "192.168.0.178");
	
    define("SITE_NAME", "Globo Rojo");
    define("INITIAL_CRED", 0.1);
    define("INITIAL_SCORE", 0 );
    define("NO_PROFILE_PHOTO", "/img/profile/noPhoto.png");
    
    define("APP_SECRET_KEY", "3KFC94J859FJH29KV9KHZ9C49393JFZ5");
    
    define("FACEBOOK_APP_ID", "498335800282857");
    define("FACEBOOK_APP_SECRET", "21b964b90788fc685baca3006b83a6d5");
    
    define("TWITTER_CONSUMER_KEY", "Hn0UctRJ96QppR8gekzBQ");
    define("TWITTER_CONSUMER_SECRET", "mRZ06odr29gJEa0fx9K1Csa5rUqTDfbM7nLCqMbbY4");
    define('TWITTER_CALLBACK', "http://".HOST_SERVER."/twitter_callback.php");
    define("CONTACT_EMAIL", "contact@meri.to");
    define("NOREPLY_EMAIL", "noreply@meri.to");    
?>