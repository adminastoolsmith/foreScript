
# foreScript Framework

foreScript is a GUI tool that uses runspacepools to execute Powershell scripts.

In every Powershell script the creator of the script has to write code to get a set of computer objects, write the actual code that executes against the computer objects, and finally write the code that displays the results of the execution of the code.

The idea behind foreScript is to remove some of this work from the creator of the script so that he/she can concentrate on the Powershell script code that is to be executed against the computer object.

foreScript for now will allow the creator of the script to import computer objects from either a file or from a DHCP server. 

foreScript expects the Powershell script to return objects and will display the output in either the console or as an HTML report. The HTML reports are based on templates.

foreScript also supports the display of custom objects that are actually C# classes using a custom formatter and  converters.

foreScript uses json for data exchange and also provides custom variables that can be accessed in the Powershell scripts.

foreScript uses Powershell runspaces, and supports a batch mode for automating the execution of scripts.

foreScript is still evolving and I would like to get feed back on how it can be improved.

forScript supports:

1. The ability to import computer objects via a file of DHCP server
2. WOL - This works by retrieving MAC addresses from a DHCP server and send out WOL packets for each MAC address
3. The ability to run Powershell scripts in batches using a CSV file as input
4. Dispalying the results of the Powershell script as an HTML report

### Further reading

[Getting Started with foreScript](http://toolsmith.brycoretechnologies.com/2015/10/getting-started-with-forescript.html#more)
