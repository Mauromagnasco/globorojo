<!-- 
 * Globo Rojo open source application
 *
 *  Copyright © 2013, 2014 by Mauro Magnasco <mauro.magnasco@gmail.com>
 *
 *  Licensed under GNU General Public License 2.0 or later.
 *  Some rights reserved. See COPYING, AUTHORS.
 *
 * @license GPL-2.0+ <http://spdx.org/licenses/GPL-2.0+>
 -->
<?php
	session_start( );
	if( isset($_SESSION['RB_ADMIN_ID']) && $_SESSION['RB_ADMIN_ID'] != "" ){
		header("location: userList.php");
	}else{
		header("location: signIn.php");
	}
	 
?>