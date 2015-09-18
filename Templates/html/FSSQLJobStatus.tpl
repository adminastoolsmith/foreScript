<!DOCTYPE html>
<!-- saved from url=(0022)about:internet -->

<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title></title>

    <style type="text/css">

        /* do the basic style for the entire table */
        body {
            margin: 0 0 0 0;
            font-size: 10pt;
        }
        table {
            border-collapse: collapse;
    	    border: 2px solid #853a07;
    	    color: #452812;
            width: 90%;
            font-family: "Times New Roman", Times, serif;
        }

        /* give some sensible defaults just in case it is an old browser */
        table td { 
            border: 1px solid #c24704;  
            vertical-align: top; 
            background-color: #fdf5f2;
        }
        table th { 
            border: 1px solid #fef7ef; 
            padding: 8pt 2pt 5pt 2pt; 
            color:white; font-weight: normal;  
            vertical-align: top; 
            background-color: #562507;
        }
        table td:first-of-type { 
            font-weight:bold; 
            font-variant: small-caps; 
            border-right: 2px solid #c24704;
        }
        table tr:nth-child(even) td:nth-child(odd){
            background-color: #ffedd9;
        }
        table tr:nth-child(even) td:nth-child(even){
            background-color: #fcf5ef;
        }
        table tr:nth-child(odd) td:nth-child(odd){
            background-color: #ffe0bd;
        }
        table tr:nth-child(odd) td:nth-child(even){
    	    background-color: #f9e4d4;
        }
        table th:nth-child(even){
    	    background-color: #703009;
        }
    </style>


<script type="text/javascript">TEMPL_JQUERY_VERSION</script>
<script type="text/javascript">TEMPL_JQUERYDATATABLE_VERSION</script>

<script type="text/javascript">
                $(document).ready(function () {
                $(document)[0].oncontextmenu = function() { return false; };
		var jsondata = TEMPL_DATA; // local object
              $('#DynamicTable').append(CreateTableView(jsondata)).fadeIn();
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