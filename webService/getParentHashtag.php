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

    $keyword = mysql_escape_string($_POST['keyword']);
    $sql = "select rb_parent_hashtag
    		  from rb_default_hashtag
    		 where lcase(rb_hashtag) = lcase('$keyword')";
    $dataKeyword = $db->queryArray( $sql );
    if( $dataKeyword == null ){
    	$result = "failed";
    }else{
    	$dataKeyword = $dataKeyword[0];
    	$data['parentHashtag'] = $dataKeyword['rb_parent_hashtag'];
    }
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
