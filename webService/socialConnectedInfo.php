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
    require_once("../simple_html_dom.php");
    require_once("../common/checkAuth.php");    
    
    $result = "success";
    $error = "";
    $data = array();
    
    $userId = mysql_escape_string($_POST['userId']);
    
    $sql = "select * from rb_user_sns where rb_user = $userId and rb_sns_type = 1";
    $dataResult = $db->queryArray( $sql );
    if( $dataResult == null ) $connectFacebook = "N";
    else $connectFacebook = "Y";

    $sql = "select * from rb_user_sns where rb_user = $userId and rb_sns_type = 2";
    $dataResult = $db->queryArray( $sql );
    if( $dataResult == null ) $connectTwitter = "N";
    else $connectTwitter = "Y";

    $data['connectFacebook'] = $connectFacebook;
    $data['connectTwitter'] = $connectTwitter;
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
