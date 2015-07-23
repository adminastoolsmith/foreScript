<!DOCTYPE html>
<!-- saved from url=(0014)about:internet -->
<!-- saved from url=(0014)about:security_powershell.exe -->
<html>
<head>
<title></title>

<style type="text/css">
BODY{background-color:#dddddd;font-family:Tahoma;font-size:12pt;}

TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;padding: 4px}
TH{border-width: 1px;padding: 4px;border-style: solid;border-color: black;background-color:black; color:white;}
TD{border-width: 1px;padding: 4px;border-style: solid;border-color: black;}


</style>


<script type="text/javascript">$TEMPL_JQUERY_VERSION</script>
<script type="text/javascript">$TEMPL_JQUERYDATATABLE_VERSION</script>

<script type="text/javascript">
                $(document).ready(function () {
		var jsondata = <%[$TEMPL_DATA<%]; // local object
                $('#display').dataTable({
                           "bPaginate": false,
                           "bLengthChange": false,
                           "bFilter": false,
                           "bSort": false,
                           "bInfo": false,
                           "bAutoWidth": false,
                           "aaData": jsondata,
                           "aoColumns": [$TEMPL_COLUMNNAMES] 
            });

         });
</script>
</head>
<body>

<h1>$TEMPL_HEADING</h1>


<br>

<table id="display">
</table>

<br>
<div id="divID"></div>

</body>
</html>