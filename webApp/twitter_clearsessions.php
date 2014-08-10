<?php
/**
 * @file
 * Clears PHP sessions and redirects to the connect page.
 */
 
/* Load and clear sessions */
if (!isset($_SESSION)) session_start();
//session_destroy();
 
/* Redirect to page with the connect to Twitter option. */
header('Location: ./twitter_login.php');
