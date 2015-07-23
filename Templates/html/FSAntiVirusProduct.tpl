<!DOCTYPE html>
<!-- saved from url=(0022)about:internet -->

<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title></title>

<style type="text/css">
BODY{background-color:#dddddd;font-family:Tahoma;font-size:12pt;}

TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;padding: 4px}
TH{border-width: 1px;padding: 4px;border-style: solid;border-color: black;background-color:black; color:white;}
TD{border-width: 1px;padding: 4px;border-style: solid;border-color: black;}


</style>


<script type="text/javascript">TEMPL_JQUERY_VERSION</script>
<script type="text/javascript">TEMPL_JQUERYDATATABLE_VERSION</script>

<script type="text/javascript">
                $(document).ready(function () {
                $(document)[0].oncontextmenu = function() { return false; };
		var jsondata = TEMPL_DATA; // local object
              $('#DynamicTable').append(CreateTableView(jsondata)).fadeIn();

              $('table tr').each(function () { 
                   
                  var defstatus = $('td:nth-child(4)', this).text();
                  var rtstatus = $('td:nth-child(5)', this).text();
                  
                  if (defstatus == 'Unknown') {
                     $(this).closest('tr').css('color', 'red');
                  };
                  
                  if (defstatus == 'Out of date') {
                     $(this).closest('tr').css('color', 'orange');
                  };

                  if (rtstatus == 'Disabled') {
                     $(this).closest('tr').css('color', 'red');
                  };
             });
              $('tr:odd').css('background-color','#E5EEFF');;

         });
</script>
</head>

<body>

<h1>TEMPL_HEADING</h1>


<br>


<br>
<div id="DynamicTable"></div>

</body>
</html>