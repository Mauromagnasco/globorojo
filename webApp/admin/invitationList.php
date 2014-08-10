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
<?php session_start(); ?>
<!DOCTYPE html>
<!--[if IE 8]> <html lang="en" class="ie8"> <![endif]-->  
<!--[if IE 9]> <html lang="en" class="ie9"> <![endif]-->  
<!--[if !IE]><!--> <html lang="en"> <!--<![endif]-->  
<head>
    <title>Red Balloon</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
       
	<?php 
		require("asset.php");
		require("../common/config.php");
		require("../common/DB_Connection.php");		
		require("../common/functions.php");
		$pageNo = 5;
	?>
	<link rel="stylesheet" type="text/css" href="http://www.datatables.net/media/blog/bootstrap_2/DT_bootstrap.css">
	
	<script type="text/javascript" src="js/jquery.dataTables.js"></script>
	<script type="text/javascript" src="js/DT_bootstrap.js"></script>
	<script type="text/javascript" src="js/invitationList.js"></script>		
</head>

<body>

<?php require_once("top.php"); ?>

<div class="container" style="min-height: 530px;">     
    <div class="row">
		<?php require_once("leftMenu.php"); ?>
        <div class="col-md-9">
			<div class="panel panel-sea margin-bottom-40">
				<div class="panel-heading">
					<h3 class="panel-title floatleft" style="line-height:30px;"><i class="icon-user"></i> Invitation Code List</h3>
					<!-- button class="floatright btn-u btn-u-red" onclick="onDeleteInvCode()" style="width: 90px;"><i class="icon-trash"></i> Delete</button -->
					<!-- button class="floatright btn-u btn-u-blue" onclick="onAddInvCode()" style="margin-right:10px;width: 90px;"><i class="icon-plus"></i> Add</button -->
					<div class="clearboth"></div>
				</div>
				<?php
					$sql = "select * 
							  from rb_invitation";
					$dataInvitation = $db->queryArray( $sql ); 
				?>
				<table class="table table-striped" id="example">
					<thead>
						<tr>
							<th style="width:100px;" class="alignCenter">No</th>
							<th class="alignCenter">Code</th>
							<th style="width:140px;" class="alignCenter">Valid Y/N</th>
						</tr>
					</thead>
					<tbody>
						<?php for($i = 0 ; $i < count( $dataInvitation); $i ++ ){?>
						<tr>
							<td class="alignCenter"><?php echo $i + 1; ?></td>
							<td class="alignCenter"><?php echo $dataInvitation[$i]['rb_code']; ?></td>
							<td class="alignCenter"><?php echo $dataInvitation[$i]['rb_valid_yn']=="Y"?"Yes":"No"; ?></td>														
						</tr>
						<?php } ?>
					</tbody>
				</table>
			</div>        			       
        </div>
    </div>          
</div>     
<?php require_once("footer.php"); ?>
</body>
</html> 