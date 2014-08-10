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

    $sql = "select rb_email_mention_yn as mentionYn
				 , rb_email_comment_yn as commentYn
    			 , rb_email_score_yn as scoreYn
    			 , rb_email_follow_yn as followYn
    			 , rb_email_unfollow_yn as unfollowYn
    		  from rb_user
    		 where rb_user = $userId";
    $dataEmail = $db->queryArray( $sql );
    $dataEmail = $dataEmail[0];
    
    $data['mentionYn'] = $dataEmail['mentionYn'];
    $data['commentYn'] = $dataEmail['commentYn'];
    $data['scoreYn'] = $dataEmail['scoreYn'];
    $data['followYn'] = $dataEmail['followYn'];
    $data['unfollowYn'] = $dataEmail['unfollowYn'];
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
