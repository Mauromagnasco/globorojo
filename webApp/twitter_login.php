<?php
/* Start session and load library. */
session_start();
require_once('twitteroauth/twitteroauth.php');
require_once('./common/config.php');

$connection = new TwitterOAuth(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET);
 
/* Get temporary credentials. */
$request_token = $connection->getRequestToken(TWITTER_CALLBACK);

/* Save temporary credentials to session. */
$_SESSION['oauth_token'] = $token = $request_token['oauth_token'];
$_SESSION['oauth_token_secret'] = $request_token['oauth_token_secret'];
$_SESSION['type'] = $_GET['type'];
if( isset($_GET['vid']) && $_GET['vid'] != "" ){
	$_SESSION['vid'] = $_GET['vid'];
}else{
	$_SESSION['vid'] = "";
}

/* If last connection failed don't display authorization link. */
switch ($connection->http_code) {
  case 200:
    /* Build authorize URL and redirect user to Twitter. */
    $url = $connection->getAuthorizeURL($token);
    header('Location: ' . $url); 
    break;
  default:
    /* Show notification if something went wrong. */
    echo 'Could not connect to Twitter. Refresh the page or try again later.';
}
