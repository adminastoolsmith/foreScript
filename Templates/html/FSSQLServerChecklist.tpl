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

            $(document)[0].oncontextmenu = function () { return false; };

            // Assign local variables to the json data variables
            // that will be updated in the template
            var query1 = TEMPL_QUERY1;
            var query2 = TEMPL_QUERY2;
            var query3 = TEMPL_QUERY3;
            var query4 = TEMPL_QUERY4;
            var query5 = TEMPL_QUERY5;
            var query6 = TEMPL_QUERY6;
            var query7 = TEMPL_QUERY7;

            // Update the div place holders with the tables
            // that are created from the jsosn data
              if (typeof(query1) != "undefined") {
                  $('#Query1').append(CreateTableView(query1));
              }

              if (typeof (query2) != "undefined") {
                  $('#Query2').append(CreateTableView(query2)).each(function () {
                      $(this).find('table td:nth-child(-2n+4)').each(function () {
                          var jsondate = new Date(parseInt($(this).text().substr(6)));
                          $(this).text(jsondate);
                      });
                      $(this).find('table td:nth-child(3)').each(function () {
                          var jsondate = new Date(parseInt($(this).text().substr(6)));
                          $(this).text(jsondate);
                      });
                  });
              }

              if (typeof (query3) != "undefined") {
                  $('#Query3').append(CreateTableView(query3)).each(function () {
                      $(this).find('table td:nth-child(3)').each(function () {
                          var jsondate = new Date(parseInt($(this).text().substr(6)));
                          $(this).text(jsondate);
                      });
                      $(this).find('table td:nth-child(4)').each(function () {
                          var jsondate = new Date(parseInt($(this).text().substr(6)));
                          $(this).text(jsondate);
                      });
                  });
              }

              if (typeof(query4) != "undefined") {
                  $('#Query4').append(CreateTableView(query4));
              }

              if (typeof (query5) != "undefined") {
                  $('#Query5').append(CreateTableView(query5)).each(function () {
                      $(this).find('table td:nth-child(6)').each(function () {
                          var jsondate = new Date(parseInt($(this).text().substr(6)));
                          $(this).text(jsondate);
                      });
                  });
              }

              if (typeof (query6) != "undefined") {
                  $('#Query6').append(CreateTableView(query6)).each(function () {
                      $(this).find('table td:nth-child(4)').each(function () {
                          var jsondate = new Date(parseInt($(this).text().substr(6)));
                          $(this).text(jsondate);
                      });
                  });
              }

              if (typeof(query7) != "undefined") {
                  $('#Query7').append(CreateTableView(query7));
              }

              $('tr:odd').css('background-color', '#E5EEFF');
        });
    </script>
</head>
<body>
    <h1>TEMPL_HEADING</h1>
    <br>
    <br>
    <h2>SQL Server Instance:</h2>
    <div id="Query1"></div>
    <br>
    <br>
    <h2>Users with SysAdmin Role:</h2>
    <div id="Query2"></div>
    <br>
    <br>
    <h2>Backup Status:</h2>
    <div id="Query3"></div>
    <br>
    <br>
    <h2>Long Running Backup:</h2>
    <div id="Query4"></div>
    <br>
    <br>
    <h2>Failed SQL Agent Jobs:</h2>
    <div id="Query5"></div>
    <br>
    <br>
    <h2>Long Running SQL Agent Jobs:</h2>
    <div id="Query6"></div>
    <br>
    <br>
    <h2>Running SQL Agent Jobs:</h2>
    <div id="Query7"></div>
    <br>
    <br>
</body>
</html>