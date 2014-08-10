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
	require_once("../common/DB_Connection.php");	
    require_once("../common/functions.php");
    require_once("../common/checkAuth.php");

    $result = "success";
    $error = "";
    $data = array();

    $userId = mysql_escape_string($_POST['userId']);
    $mentionYn = mysql_escape_string($_POST['mentionYn']);
    $scoreYn = mysql_escape_string($_POST['scoreYn']);
    $commentYn = mysql_escape_string($_POST['commentYn']);
    $followYn = mysql_escape_string($_POST['followYn']);
    $unfollowYn = mysql_escape_string($_POST['unfollowYn']);

	$sql = "update rb_user
			   set rb_email_mention_yn = '$mentionYn'
			     , rb_email_score_yn = '$scoreYn'
			     , rb_email_comment_yn = '$commentYn'
			     , rb_email_follow_yn = '$followYn'
			     , rb_email_unfollow_yn = '$unfollowYn'
			 where rb_user = $userId";
	$db->query( $sql );
	
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
